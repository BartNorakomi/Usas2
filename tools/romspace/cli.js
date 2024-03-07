#!/usr/bin/env node
import fs from "fs";

async function main() {
	if (process.argv.length < 3) {
		console.log(`Usage: npx romspace my-ascii16.rom`);
		process.exit(1);
	}

	const path = process.argv[2];

	const rom = await fs.promises.readFile(path);

	const hex = (value, padding = 0) => value.toString(16).padStart(padding, " ");
	const percent = (numerator, denominator) => ((100 * numerator / denominator).toFixed(0)).padStart(3, " ") + "%";

	let totalUsed = 0;
	for (let bank = 0; bank < rom.length / 0x4000; bank++) {
		const bankAddress = bank * 0x4000;
		const bankSize = Math.min(rom.length - (bank * 0x4000), 0x4000);
		let used = bankSize;
		const spaceMarker = rom[bankAddress + used - 1];
		if (spaceMarker == 0x00 || spaceMarker == 0xFF) {
			while (used > 0 && rom[bankAddress + used - 1] == spaceMarker) {
				used--;
			}
		}
		const free = bankSize - used;
		totalUsed += used;

		console.log(`Bank ${hex(bank, 3)}, used: ${hex(used, 4)} (${percent(used, bankSize)}), free: ${hex(free, 4)} (${percent(free, bankSize)})`);
	}
	const totalFree = rom.length - totalUsed;
	
	console.log();
	console.log(`Total used: ${hex(totalUsed, 6)} (${percent(totalUsed, rom.length)}), free: ${hex(totalFree, 6)} (${percent(totalFree, rom.length)})`)
}

await main();
