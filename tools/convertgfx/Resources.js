import fs from "fs";
import fspath from "path";
import { FormatPNG, FormatBMP, FormatSC5, FormatScreen5, FormatPalette } from "./Format.js";
import { TransformGamma, TransformQuantisePalette, TransformPrunePalette,
	TransformSwizzlePalette, TransformFixedPalette, TransformSlice } from "./TransformImage.js";
import { Color } from "./Image.js";

export class Resources {
	constructor() {
		this.images = [];
	}

	addJSON(json) {
		if (json.group) {
			for (const child of json.group) {
				this.addJSON({ ...json, group: undefined, ...child, path: fspath.resolve(json.path ?? "", child.path ?? "") });
			}
		} else {
			this.images.push(new ResourceImage(json));
		}
	}

	async process() {
		return await Promise.all(this.images.map(image => image.process()));
	}
}

export class ResourceImage {
	constructor(json) {
		this.source = resolveRelativePath(json.path, json.source);
		this.fixedPalette = resolveRelativePath(json.path, json.fixedPalette);
		this.targetScreen5 = resolveRelativePath(json.path, json.targetScreen5);
		this.targetPalette = resolveRelativePath(json.path, json.targetPalette);
		this.targetSC5 = resolveRelativePath(json.path, json.targetSC5);
		this.targetBMP = resolveRelativePath(json.path, json.targetBMP);
		this.transforms = [
			json.slice ? new TransformSlice(json.slice.x, json.slice.y, json.slice.width, json.slice.height) : [],
			new TransformGamma(json.gamma),
			new TransformQuantisePalette(7),
			json.swizzlePalette ? new TransformSwizzlePalette(json.swizzlePalette) : [],
			json.prunePalette ? new TransformPrunePalette() : [],
			Array.isArray(json.fixedPalette) ? new TransformFixedPalette(json.fixedPalette.map(c => Array.isArray(c) ? new Color(c[0] ?? 0, c[1] ?? 0, c[2] ?? 0, 7) : null)) : [],
		].flat();
	}

	async process() {
		try {
			let image = await this.loadImage();
			if (this.fixedPalette) {
				const palette = await this.loadFixedPalette();
				this.transforms.push(new TransformFixedPalette(palette));
			}
			image = this.transforms.reduce((image, transform) => transform.apply(image), image);
			await this.save(image);
			return image;
		} catch(error) {
			console.error(`[${this.source}]`);
			console.error(error);
			return undefined;
		}
	}

	async loadImage() {
		const data = await fs.promises.readFile(this.source);
		if (data[0] === 0x42 && data[1] === 0x4d) {
			return await new FormatBMP().decode(data);
		} else if (data[0] === 0x89 && data[1] === 0x50 && data[2] === 0x4e && data[3] === 0x47) {
			return await new FormatPNG().decode(data);
		} else if (data[0] === 0xFE && this.source.endsWith("5")) {
			return await new FormatSC5().decode(data);
		} else {
			throw new Error("Unrecognised image format.");
		}
	}

	async loadFixedPalette() {
		const data = await fs.promises.readFile(this.fixedPalette);
		return (await new FormatPalette().decode(data)).palette.slice(0, 16);
	}

	async save(image) {
		if (this.targetScreen5) {
			await fs.promises.writeFile(this.targetScreen5, await new FormatScreen5().encode(image));
		}
		if (this.targetPalette) {
			await fs.promises.writeFile(this.targetPalette, await new FormatPalette().encode(image));
		}
		if (this.targetSC5) {
			await fs.promises.writeFile(this.targetSC5, await new FormatSC5().encode(image));
		}
		if (this.targetBMP) {
			await fs.promises.writeFile(this.targetBMP, await new FormatBMP().encode(image));
		}
	}
}

function resolveRelativePath(base, path) {
	return typeof path == "string" ? fspath.resolve(base ?? "", path) : undefined;
}

export class ResourceOverride {
	constructor(path, value) {
		this.path = path.split(".").map(part => /^\d+$/.test(part) ? parseInt(part, 10) : part);
		this.value = value == "true" ? true : value == "false" ? false : value == "null" ? null :
			value == "undefined" ? undefined : /^[\-\d\[\{\"]/.test(value[0]) ? JSON.parse(value) : value;
	}

	apply(json) {
		const path = this.path;
		for (let i = 0; i < path.length - 1; i++) {
			if (path[i] in json) {
				json = json[path[i]];
			} else if (typeof path[i + 1] == "number") {
				json = json[path[i]] = [];
			} else if (typeof path[i + 1] == "string") {
				json = json[path[i]] = {};
			} else {
				throw new Error("Invalid path element type.");
			}
		}
		json[path.at(-1)] = this.value;
	}
}
