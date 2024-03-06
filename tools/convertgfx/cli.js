#!/usr/bin/env node
import fs from "fs";
import { Resources } from "./Resources.js";

async function main() {
	if (process.argv.length < 3) {
		console.log(`Usage: npx convertgfx resources.json`);
		process.exit(1);
	}

	const path = process.argv[2];

	console.log(`Loading resources manifest...`);
	const resources = new Resources(JSON.parse(await fs.promises.readFile(path)), path);
	console.log(`Processing ${resources.images.length} images...`);
	const images = await resources.process();
	console.log(`Done.`);

	if (images.some(image => image === undefined)) {
		process.exit(1);
	}
}

await main();
