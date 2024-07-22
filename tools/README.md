# Usas2 tools

## Node.js scripts

Before you begin:

1. Install the latest LTS version of [Node.js](https://nodejs.org/en)
2. Run `npm install` in the root of the Usas2-project.

Now you can run the scripts (everywhere in the project) via `npm run`:

* `npm run romspace`
  * This determines the unused space in **Engine\Usas2.rom**.
* `npm run convertgfx`
  * This converts all images as specified in **grafx\convertgfx.json** in one go.

Additionally you can also run the scripts individually with your own command line parameters via `npx` (with the X of eXecute):

* `npx romspace Engine\Usas2.rom`
  * This determines the unused space in **Engine\Usas2.rom**.
* `npx convertgfx grafx\convertgfx.json`
  * This converts all images as specified in **grafx\convertgfx.json** in one go.
* `npx convertgfx --source KarniMata.tiles.bmp --fixedPalette sKarniMataPalette.PL --targetScreen5 KarniMata.tiles.SC5 --gamma 2.2`
  * (For this specific example should be called from **grapx\tilesheets** where those files exist.)
  * This specifically converts the **KarniMata.tiles.bmp** image with the given parameters.
* `npx convertgfx --help`
  * This shows an overview of the options for the command line (as seen above) and the JSON.


#ro
npx convertgfx --path "..\grapx\AreaSigns" --source ".\01-Hub.bmp" --targetScreen5 ".\01-hub.sc5" --fixedPalette "C:\Users\rvand\GIT\Usas2\grapx\tilesheets\Karnimata.tiles.PL"

gci "..\grapx\AreaSigns\*-*.bmp"|%{npx convertgfx --path "..\grapx\AreaSigns" --source ".\$($_.basename).bmp" --targetScreen5 ".\$($_.basename).sc5" --fixedPalette "C:\Users\rvand\GIT\Usas2\grapx\tilesheets\Karnimata.tiles.PL"}

