
String settingsPath = "data/settings.json";

Boolean RECORD;

String OUTPUT_PATH;
String SKETCH_NAME;

int GFX_WIDTH;
int GFX_HEIGHT;

int FPS;

int START_TIME;

int TOTAL_FRAMES;

String KEYSTONE_DATA_PATH;
Boolean KEYSTONE_DATA_LOAD;

String BACKGROUND_IMAGE_PATH;
Boolean BACKGROUND_IMAGE_ACTIVE;

float PROJECTOR_BRIGHTNESS;

Boolean SECONDARY_DISPLAY;

float totalWidth, totalHeight;

float time, timeStep;

SurfaceData[] surfacesDatum;


void loadSettings() {
  JSONObject settings = loadJSONObject(settingsPath);

  RECORD = settings.getBoolean("record");

  OUTPUT_PATH = settings.getString("output_path");
  SKETCH_NAME = settings.getString("sketch_name");

  GFX_WIDTH = settings.getInt("gfx_width");
  GFX_HEIGHT = settings.getInt("gfx_height");

  TOTAL_FRAMES = settings.getInt("total_frames");

  FPS = settings.getInt("fps");
  START_TIME = settings.getInt("start_time");

  // get data abstractions of cornerpin surfaces
  JSONArray surfaceArray = settings.getJSONArray("surfaces");
  surfacesDatum = new SurfaceData[ surfaceArray.size() ];

  for(int i=0; i < surfacesDatum.length; i++) {
    JSONObject surface = surfaceArray.getJSONObject(i);
    int w = surface.getInt("w");
    int h = surface.getInt("h");
    int res = surface.getInt("res");

    int tx = surface.getInt("tx");
    int ty = surface.getInt("ty");
    int tw = surface.getInt("tw");
    int th = surface.getInt("th");

    surfacesDatum[i] = new SurfaceData(w, h, res, tx, ty, tw, th);
  }

  // path to keystone lib's calibration file
  KEYSTONE_DATA_PATH = settings.getString("keystone_data_path");

  // should keystone calibration be loaded at start?
  KEYSTONE_DATA_LOAD = settings.getBoolean("keystone_data_load");

  // background image is used for mocking up projections in physical spaces
  BACKGROUND_IMAGE_PATH = settings.getString("background_image_path");

  // are we using the background image?
  BACKGROUND_IMAGE_ACTIVE = settings.getBoolean("background_image_active");

  // when using a background image
  PROJECTOR_BRIGHTNESS = settings.getFloat("projector_brightness");

  // if a second display is used should we use it?
  SECONDARY_DISPLAY = settings.getBoolean("secondary_display");

}

void parseSettings() {

  // float version for easier calculations
  totalWidth = GFX_WIDTH;
  totalHeight = GFX_HEIGHT;

  // start time
  time = START_TIME;

  // time increment
  timeStep = 1.0/FPS;

}

// a simple data abstraction of a cornerpin surface
class SurfaceData {
  int w, h, res;
  int tx, ty, tw, th;

  SurfaceData(int _w, int _h, int _res, int _tx, int _ty, int _tw, int _th) {
    w = _w;
    h = _h;
    res = _res;

    // source texture coordinates to grab only part of PGraphics
    tx = _tx;
    ty = _ty;
    tw = _tw;
    th = _th;

  }
}
