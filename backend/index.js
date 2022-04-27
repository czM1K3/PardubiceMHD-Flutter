import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import compression from "compression";
import http from "http";
import { Server as SocketServer } from "socket.io";

const busesName = "buses";

const app = express();
const server = http.createServer(app);
const io = new SocketServer(server, {
	cors: {
		origin: "*",
	},
});
let cache = null;

const getBusses = async () => {
	try {
		const raw = await fetch(process.env.FETCH_URL);
		return await raw.json();
	} catch (e) {
		console.log(e);
		return null;
	}
};

const busFetch = async (_req, res) => {
	const data = await getBusses(res);
	if (data) {
		res.status(200).json(data);
	}
	else {
		res.status(500).json({ error: "Failed to fetch data" });
	}
}

app.use(
	cors({
		origin: "*",
	})
);

app.use(compression());

app.post("/api/buses", busFetch);
app.get("/api/buses", busFetch);

app.get("/api/count", (_req, res) => {
	res.status(200).json({ count: io.engine.clientsCount });
});

app.use(
	express.static("public", {
		cacheControl: true,
		maxAge: 60 * 60 * 24,
	})
);

setInterval(async () => {
	if (io.engine.clientsCount !== 0) {
		const buses = await getBusses();
		if (JSON.stringify(buses) !== JSON.stringify(cache)) {
			cache = buses;
			io.emit(busesName, buses);
		}
	}
}, 900);

io.on("connection", (socket) => {
	socket.join(busesName);
});

server.listen(3000, () => {
	console.log("Server is running on port 3000");
});
