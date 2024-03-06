#!/usr/bin/env node
import fs from "fs";
import { Resources, ResourceOverride } from "./Resources.js";

async function main() {
	let resourcesPath = undefined;
	let resourcesJson = undefined;
	let help = false;
	const overrides = [];

	for (let i = 2; i < process.argv.length; i++) {
		const arg = process.argv[i];
		if (arg.startsWith("-") && arg.length > 1) {
			if (arg == "-h" || arg == "--help") {
				help = true;
			} else if (arg.startsWith("--") && arg.length > 2) {
				if (i + 1 >= process.argv.length)
					throw new Error("Missing arguments.");
				overrides.push(new ResourceOverride(arg.slice(2), process.argv[++i]));
			} else {
				throw new Error(`Unsupported option: ${arg}`);
			}
		} else if (resourcesJson === undefined) {
			resourcesPath = arg;
			resourcesJson = JSON.parse(await fs.promises.readFile(resourcesPath));
		} else {
			throw new Error(`Too many arguments: ${process.argv.slice(i).join(" ")}`);
		}
	}

	if (overrides.length > 0 && resourcesJson === undefined) {
		resourcesPath = ".";
		resourcesJson = {};
	}

	if (help || resourcesJson === undefined) {
		console.log(`Usage: npx convertgfx [<options>] [resources.json]`);
		console.log();
		console.log(`Options:`);
		console.log(`  --help Show this help text`);
		console.log(`  --source Input BMP or PNG file.`);
		console.log(`  --targetScreen5 Output raw screen 5 pixel data file.`);
		console.log(`  --targetPalette Output raw palette data file.`);
		console.log(`  --targetSC5 Output MSX-BASIC format .SC5 image file to use with BLOAD ,S.`);
		console.log(`  --targetBMP Output BMP-format file for debugging.`);
		console.log(`  --gamma Gamma to use when converting, default 2.2.`);
		console.log(`  --slice Take a slice of the image, with dimensions {x: …, y: …, width: …, height: …}.`);
		console.log(`  --swizzlePalette Map palette to new positions, with array of new indices.`);
		console.log(`  --prunePalette De-duplicate and remove unused palette colours, if true.`);
		console.log(`  --fixedPalette Fix colour positions in palette, with [r, g, b] array or raw palette data file.`);
		console.log();
		console.log(`When options are specified the resources json is optional.`);
		console.log(`If a resources json is provided, the options specify overrides.`);
		return 0;
	}

	const resources = new Resources(resourcesJson, resourcesPath, overrides);
	console.log(`Processing ${resources.images.length} images...`);
	const images = await resources.process();
	console.log(`Done.`);

	if (images.some(image => image === undefined)) {
		process.exit(1);
	}

	return 0;
}

process.exit(await main());
