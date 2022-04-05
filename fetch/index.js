import express from "express";
import fetch from "node-fetch";
import cors from "cors";

const getBusses = async (_req, res) => {
	const raw = await fetch("https://mhd.kacis.eu/api/buses", {
		method: "POST",
		body: '{"key":"869f749a-1b72-4ccb-b888-cb0aef8e0aea"}',
	});
	const data = await raw.json();
	res.status(200).json(data);
};

const app = express();

app.use(cors({
	origin: "*",
}))

app.post("/api/buses", getBusses);
app.get("/api/buses", getBusses);

app.use(express.static('public',{
	cacheControl: true,
	maxAge: 60 * 60 * 24,
}))

app.listen(3000, () => {
	console.log("Server is running on port 3000");
});
