export class Image {
	constructor(pixels, palette) {
		this.pixels = pixels;
		this.palette = palette;
	}

	static new(image) {
		return new Image(image.pixels, image.palette);
	}
}

export class Array2D {
	constructor(width, height, getter) {
		this.width = width;
		this.height = height;
		this.getter = getter;
	}

	get(x, y) {
		if (x < 0 || x >= this.width || y < 0 || y >= this.height) {
			throw new Error("Coordinates out of range.");
		}
		return this.getter(x, y);
	}

	static ofArray(array, width, height) {
		if (array.length != width * height) {
			throw new Error("Array data incomplete.");
		}
		return new Array2D(width, height, (x, y) => array[y * width + x]);
	}

	toArray() {
		const array = [];
		for (let y = 0, i = 0; y < this.height; y++) {
			for (let x = 0; x < this.width; x++, i++) {
				array.push(this.getter(x, y));
			}
		}
		return array;
	}

	apply() {
		return Array2D.ofArray(this.toArray(), this.width, this.height);
	}

	map(mapFunction) {
		return new Array2D(this.width, this.height, (x, y) => mapFunction(this.get(x, y), x, y, this));
	}

	tile(width, height) {
		if (this.width % width != 0 || this.height % height != 0) {
			throw new Error("Not an integer multiple of tile dimensions.");
		}
		const tiles = [];
		for (let y = 0; y < this.height; y += height) {
			for (let x = 0; x < this.width; x += width) {
				tiles.push(this.slice(x, y, width, height));
			}
		}
		return Array2D.ofArray(tiles, Math.floor(this.width / width), Math.floor(this.height / height));
	}

	slice(xOffset = 0, yOffset = 0, width = this.width - xOffset, height = this.height - yOffset) {
		if (xOffset < 0 || (xOffset + width) > this.width || yOffset < 0 || (yOffset + height) > this.height) {
			throw new Error("Slice coordinates out of range.");
		}
		return new Array2D(width, height, (x, y) => this.get(xOffset + x, yOffset + y));
	}
}

export class Color {
	static transparent = new Color(0, 0, 0, Infinity);

	constructor(r, g, b, w) {
		this.r = r;
		this.g = g;
		this.b = b;
		this.w = w;
	}

	static scalar(scalar) {
		return new Color(scalar, scalar, scalar, scalar);
	}

	multiply(other) {
		return new Color(this.r * other.r, this.g * other.g, this.b * other.b, this.w * other.w);
	}

	power(exponent) {
		return new Color(Math.pow(this.r, exponent.r), Math.pow(this.g, exponent.g), Math.pow(this.b, exponent.b), Math.pow(this.w, exponent.w));
	}

	dot(other) {
		return this.r * other.r + this.g * other.g + this.b * other.b + this.w * other.w;
	}

	project(scale) {
		return new Color(this.r * scale / this.w, this.g * scale / this.w, this.b * scale / this.w, scale);
	}

	round() {
		return new Color(Math.round(this.r), Math.round(this.g), Math.round(this.b), Math.round(this.w));
	}

	equals(other) {
		return this.r === other.r && this.g === other.g && this.b == other.b && this.w == other.w;
	}
}
