import express from "express";
import fetch from "node-fetch";
import cors from "cors";
import compression from "compression";

const getBusses = async (_req, res) => {
	const raw = await fetch("https://mhd.kacis.eu/api/buses", {
		method: "POST",
		body: '{"key":"09658f18-0f8c-4909-a571-0bc6b4acfbec"}',
	});
	const data = await raw.json();
	res.status(200).json(data);
};

const app = express();

app.use(cors({
	origin: "*",
}));

app.use(compression());

app.post("/api/buses", getBusses);
app.get("/api/buses", getBusses);

app.use(express.static('public',{
	cacheControl: true,
	maxAge: 60 * 60 * 24,
}));

app.listen(3000, () => {
	console.log("Server is running on port 3000");
});
