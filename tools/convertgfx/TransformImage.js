import { Image, Color } from "./Image.js";

export class TransformImage {
	apply(image) {
		return image;
	}
}

export class TransformGamma extends TransformImage {
	constructor(gamma = 2.2) {
		super();
		this.gamma = gamma;
	}

	apply(image) {
		if (this.gamma === 2.2) {
			return image;
		}
		const palette = image.palette.map(color => color.power(Color.scalar(this.gamma / 2.2)));
		return Image.new({ ...image, palette });
	}
}

export class TransformQuantisePalette extends TransformImage {
	constructor(scale = 7) {
		super();
		this.scale = scale;
	}

	apply(image) {
		const palette = image.palette.map(color => color.project(this.scale).round());
		return Image.new({ ...image, palette });
	}
}

export class TransformPrunePalette extends TransformImage {
	apply(image) {
		return this.prune(this.dedupe(image));
	}

	dedupe(image) {
		const indexMap = [...Array(image.palette.length).keys()];
		for (let index1 = 0; index1 < image.palette.length; index1++) {
			for (let index2 = index1 + 1; index2 < image.palette.length; index2++) {
				if (indexMap[index2] == index2 && image.palette[index1].equals(image.palette[index2])) {
					indexMap[index2] = index1;
				}
			}
		}
		const pixels = image.pixels.map(index => indexMap[index] ?? index);
		return Image.new({ ...image, pixels });
	}

	prune(image) {
		const frequencies = Array(image.palette.length).fill(0);
		for (let y = 0; y < image.pixels.height; y++) {
			for (let x = 0; x < image.pixels.width; x++) {
				frequencies[image.pixels.get(x, y)] += 1;
			}
		}
		if (frequencies.length > image.palette.length) {
			throw new Error("Palette index out of bounds.");
		}
		const palette = [];
		const indexMap = Array(frequencies.length).fill(frequencies.length - 1);
		for (const [index, count] of frequencies.entries()) {
			if (count > 0) {
				indexMap[index] = palette.length;
				palette.push(image.palette[index]);
			}
		}
		const pixels = image.pixels.map(index => indexMap[index] ?? index);
		return Image.new({ ...image, pixels, palette });
	}
}

export class TransformSwizzlePalette extends TransformImage {
	constructor(swizzle = []) {
		super();
		this.swizzle = swizzle;
	}

	apply(image) {
		if (this.swizzle.length == 0) {
			return image;
		}
		const pixels = image.pixels.map(index => this.swizzle[index] ?? index);
		const palette = this.palette.slice(0);
		for (let index = this.swizzle.length - 1; index >= 0; index--) {
			palette[this.swizzle[index] ?? index] = this.palette[index];
		}
		return Image.new({ ...image, pixels, palette });
	}
}

export class TransformFixedPalette extends TransformImage {
	constructor(fixedPalette = []) {
		super();
		this.fixedPalette = fixedPalette;
	}

	apply(image) {
		if (this.fixedPalette.length == 0) {
			return image;
		}
		const palette = this.fixedPalette.slice(0);
		const indexMap = [];
		for (const [index, color] of image.palette.entries()) {
			const fixedIndex = palette.findIndex(fixedColor => fixedColor?.equals(color));
			if (fixedIndex >= 0) {
				indexMap[index] = fixedIndex;
			} else {
				const newIndex = palette.findIndex(fixedColor => !fixedColor);
				if (newIndex >= 0) {
					indexMap[index] = newIndex;
					palette[newIndex] = color;
				} else {
					indexMap[index] = palette.length;
					palette.push(color);
				}
			}
		}
		for (let index = 0; index < palette.length; index++) {
			if (!palette[index]) {
				palette[index] = Color.transparent;
			}
		}
		const pixels = image.pixels.map(index => indexMap[index] ?? index);
		return Image.new({ ...image, pixels, palette });
	}
}

export class TransformSlice extends TransformImage {
	constructor(x, y, width, height) {
		super();
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	apply(image) {
		const pixels = image.pixels.slice(this.x, this.y, this.width, this.height);
		return Image.new({ ...image, pixels });
	}
}
