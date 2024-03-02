import PNG from "png-js";
import BMP from "bmp-js";
import { Image, Array2D, Color } from "./Image.js";

export class Format {
	async decode(buffer) {
		throw new Error("Not implemented.");
	}

	async encode(input) {
		throw new Error("Not implemented.");
	}
}

export class FormatPNG extends Format {
	async decode(buffer) {
		const png = new PNG(buffer);
		const colorRGBA = (r, g, b, a) => a < 128 ? Color.transparent : new Color(r, g, b, 255);
		if (!png.transparency.indexed) {  // hackfix PNG library if no tRNS header is present
			png.transparency.indexed = Array(png.palette.length / 3).fill(255);
		}

		if (png.colorType == 3) {
			const pngPalette = png.decodePalette();
			const palette = [];
			for (let i = 0; i < pngPalette.length; i += 4) {
				palette.push(colorRGBA(pngPalette[i], pngPalette[i + 1], pngPalette[i + 2], pngPalette[i + 3]));
			}

			const pngPixels = await new Promise(resolve => png.decodePixels(pixels => resolve(pixels)));
			const pixels = new Uint32Array(pngPixels);
			return new Image(Array2D.ofArray(pixels, png.width, png.height), palette);
		} else {
			const pngPalette = png.decodePalette();
			const palette = [];
			const paletteLut = new Map();
			for (let i = 0; i < pngPalette.length; i += 4) {
				const [r, g, b, a] = [pngPalette[i], pngPalette[i + 1], pngPalette[i + 2], pngPalette[i + 3]];
				paletteLut.set(r << 24 | g << 16 | b << 8 | a, i / 4);
				palette.push(colorRGBA(r, g, b, a));
			}

			const pngPixels = await new Promise(resolve => png.decode(pixels => resolve(pixels)));
			const pixels = new Uint32Array(png.width * png.height);
			for (let i = 0, j = 0; i < pngPixels.length; i += 4, j++) {
				const rgba = pngPixels[i + 0] << 24 | pngPixels[i + 1] << 16 | pngPixels[i + 2] << 8 | pngPixels[i + 3];
				if (!paletteLut.has(rgba)) {
					paletteLut.set(rgba, palette.length);
					palette.push(colorRGBA(pngPixels[i + 0], pngPixels[i + 1], pngPixels[i + 2], pngPixels[i + 3]));
				}
				pixels[j] = paletteLut.get(rgba);
			}

			return new Image(Array2D.ofArray(pixels, png.width, png.height), palette);
		}
	}
}

export class FormatBMP extends Format {
	async decode(buffer) {
		const bmp = BMP.decode(buffer);
		const colorRGBA = (r, g, b, a) => a < 128 ? Color.transparent : new Color(r, g, b, 255);
		const parseAlpha = (a) => bmp.bitPP == 15 || bmp.bitPP == 32 ? a : 255;

		const palette = bmp.palette ? bmp.palette.map(c => colorRGBA(c.red, c.green, c.blue, c.alpha)) : [];
		const paletteLut = new Map(bmp.palette ? bmp.palette.map((c, i) => [c.red << 24 | c.green << 16 | c.blue << 8 | c.alpha, i]) : []);

		const pixels = new Uint32Array(bmp.width * bmp.height);
		for (let i = 0, j = 0; i < bmp.data.length; i += 4, j++) {
			const rgba = bmp.data[i + 3] << 24 | bmp.data[i + 2] << 16 | bmp.data[i + 1] << 8 | parseAlpha(bmp.data[i + 0]);
			if (!paletteLut.has(rgba)) {
				paletteLut.set(rgba, palette.length);
				palette.push(colorRGBA(bmp.data[i + 3], bmp.data[i + 2], bmp.data[i + 1], parseAlpha(bmp.data[i + 0])));
			}
			pixels[j] = paletteLut.get(rgba);
		}
		return new Image(Array2D.ofArray(pixels, bmp.width, bmp.height), palette);
	}

	async encode(image) {
		const palette = image.palette.map(color => color.project(255).round());
		const data = new Uint8Array(image.pixels.width * image.pixels.height * 4);
		for (let y = 0, i = 0; y < image.pixels.height; y++) {
			for (let x = 0; x < image.pixels.width; x++, i += 4) {
				const color = palette[image.pixels.get(x, y)];
				data[i + 0] = color.a;
				data[i + 1] = color.b;
				data[i + 2] = color.g;
				data[i + 3] = color.r;
			}
		}
		return new BMP.encode({ data, width: image.pixels.width, height: image.pixels.height }).data;
	}
}

export class FormatSC5 extends Format {
	constructor() {
		super();
		this.formatScreen5 = new FormatScreen5();
		this.formatPalette = new FormatPalette();
	}

	async decode(buffer) {
		if (buffer.length != 0x76A7) {
			throw new Error("Invalid data size.");
		}
		if (buffer[0] != 0xFE ||
			(buffer[1] | buffer[2] << 8) != 0x0000 ||
			(buffer[3] | buffer[4] << 8) != 0x769F ||
			(buffer[5] | buffer[6] << 8) != 0x0000) {
			throw new Error("Invalid data header.");
		}

		const { pixels } = await this.formatScreen5.decode(buffer.subarray(7 + 0x0000, 7 + 0x6A00));
		const { palette } = await this.formatPalette.decode(buffer.subarray(7 + 0x7680, 7 + 0x76A0));
		return new Image(pixels, palette);
	}

	async encode(image) {
		if (image.pixels.width != 256 && image.pixels.height != 212) {
			throw new Error("Invalid image size.");
		}

		const data = new Uint8Array(0x76A7);
		data.set([0xFE, 0x00, 0x00, 0x9F, 0x76, 0x00, 0x00]);
		data.set(await this.formatScreen5.encode(image), 7 + 0x0000);
		data.set(await this.formatPalette.encode(image), 7 + 0x7680);
		return data;
	}
}

export class FormatScreen5 extends Format {
	async decode(buffer) {
		if (buffer.length & 127) {
			throw new Error("Invalid data size.");
		}

		const width = 256;
		const height = buffer.length / 128;
		const pixels = new Uint32Array(width * height);
		for (let i = 0, j = 0; i < buffer.length; i++, j += 2) {
			pixels[j + 0] = buffer[i] >> 4 & 0xF;
			pixels[j + 1] = buffer[i] & 0x0F;
		}
		return new Image(Array2D.ofArray(pixels, width, height), []);
	}

	async encode(image) {
		if (image.pixels.width & 1) {
			throw new Error("Image width is not even.");
		}

		const data = new Uint8Array((image.pixels.width * image.pixels.height) / 2);
		for (let y = 0, i = 0; y < image.pixels.height; y++) {
			for (let x = 0; x < image.pixels.width; x += 2, i++) {
				data[i] = (image.pixels.get(x, y) & 15) << 4 | (image.pixels.get(x + 1, y) & 15);
			}
		}
		return data;
	}
}

export class FormatPalette extends Format {
	async decode(buffer) {
		if (buffer.length & 1) {
			throw new Error("Invalid data size.");
		}
		const palette = [];
		for (let i = 0; i < buffer.length; i += 2) {
			palette.push(new Color(buffer[i] >> 4 & 0x7, buffer[i + 1] & 0x7, buffer[i] & 0x7, 7));
		}
		return new Image(Array2D.ofArray([], 0, 0), palette);
	}

	async encode(image) {
		if (image.palette.some(color => color.w != 7 && color.w != Infinity)) {
			throw new Error("Colours have not been quantised.");
		}
		if (image.palette.length > 16) {
			throw new Error("Palette too large.");
		}
		const palette = image.palette.slice(0, 16);
		for (let i = palette.length; i < 16; i++) {
			palette.push(Color.transparent);
		}
		const colorWords = palette.map(color => color.r << 4 | color.g << 8 | color.b);
		return new Uint8Array(colorWords.map(word => [word & 0xFF, word >> 8 & 0xFF]).flat());
	}
}
