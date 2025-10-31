// Keystone lib https://github.com/davidbouchard/keystone
// http://deadpixel.ca/keystone/reference/index.html
import deadpixel.keystone.*;

Keystone ks;
CornerPinSurface[] surfaces;

PGraphics gfx;

Content content;

HUD hud;

PVector cursor;

PImage backgroundImage;

Boolean calibrating = false;

void settings() {
  loadSettings();
  parseSettings();
  
  pixelDensity(1);

  if(SECONDARY_DISPLAY) fullScreen(P2D, 2);
  else fullScreen(P3D);

  //smooth(8);
  noSmooth();
}

void setup() {

  background(0);
  frameRate(FPS);
  noCursor();
  

  gfx = createGraphics(GFX_WIDTH, GFX_HEIGHT, P2D);
  
  // init keystone surfaces
  ks = new Keystone(this);
  surfaces = new CornerPinSurface[surfacesDatum.length];

  for(int i=0; i < surfacesDatum.length; i++) {
    int w = surfacesDatum[i].w;
    int h = surfacesDatum[i].h;
    int res = surfacesDatum[i].res;

    surfaces[i] = ks.createCornerPinSurface(w, h, res);
  }
  
  cursor = surfaces[0].getTransformedMouse();

  if(KEYSTONE_DATA_LOAD) ks.load(KEYSTONE_DATA_PATH);

  // load background image
  if(BACKGROUND_IMAGE_ACTIVE) backgroundImage = loadImage(BACKGROUND_IMAGE_PATH);

  // content manager, separate from main app so it can be modified
  content = new Content();
  content.render();

  hud = new HUD();
}

void draw() {

  // if calibrating show cursor
  if(ks.isCalibrating()) cursor();
  else noCursor();

  background(0);

  // background for simulating projection
  if(BACKGROUND_IMAGE_ACTIVE) renderBackgroundImage();

  //// if using background image simulate projection
  if(BACKGROUND_IMAGE_ACTIVE){
    tint(PROJECTOR_BRIGHTNESS); // simulate projector brightness
    blendMode(SCREEN); // simulate projector light
  }

  // display keystone surfaces
  for(int i=0; i < surfacesDatum.length; i++) {
    int tx = surfacesDatum[i].tx;
    int ty = surfacesDatum[i].ty;
    int tw = surfacesDatum[i].tw;
    int th = surfacesDatum[i].th;

    surfaces[i].render(gfx, tx, ty, tw, th);
  }
  
  cursor = surfaces[0].getTransformedMouse();
  
  // render gfx
  content.render();

  // record frames
  if (RECORD) recordFrames(frameCount);

  // show heads up display
  //if(!RECORD) hud.render();

  // increase time
  time += timeStep;

}


void recordFrames(int frameNumber) {

  String frameString = nf(frameNumber, 4);

  String fileName = SKETCH_NAME+"_"+frameString+".png";
  String path = OUTPUT_PATH;

  save(path+fileName);

  if (frameCount == TOTAL_FRAMES ) exit();
}

void renderBackgroundImage() {
  pushStyle();
  noTint();
  imageMode(CENTER);

  float x = width*.5;
  float y = height*.5;
  float w = 0;
  float h = 0;

  if(backgroundImage.width >= backgroundImage.height) {
    w = width;
    h = backgroundImage.height * (w/backgroundImage.width );
  } else {
    h = height;
    w = backgroundImage.width  * (h/backgroundImage.height );
  }

  image(backgroundImage, x, y, w, h);
  popStyle();
}

void keyPressed() {
  content.keyPressRelay(key);
  
  switch(key) {
  case 'c':
    // enter/leave calibration mode, where surfaces can be warped
    // and moved
    calibrating = !calibrating;
    ks.toggleCalibration();
    break;

  case 'l':
    // loads the saved layout
    ks.load(KEYSTONE_DATA_PATH);
    break;

  case 's':
    // saves the layout
    ks.save(KEYSTONE_DATA_PATH);
    break;
  }
}
