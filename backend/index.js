import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import compression from "compression";
import http from "http";
import { Server as SocketServer } from "socket.io";

const busesName = "buses";

const app = express();
const server = http.createServer(app);
const io = new SocketServer(server);
let cache = null;

const getBusses = async () => {
	try {
		const raw = await fetch("https://mhd.kacis.eu/api/buses", {
			method: "POST",
			body: '{"key":"09658f18-0f8c-4909-a571-0bc6b4acfbec"}',
		});
		return await raw.json();
	} catch {
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
}, 1000);

io.on("connection", (socket) => {
	socket.join(busesName);
});

server.listen(3000, () => {
	console.log("Server is running on port 3000");
});
