class Content {

  PShader shaderPaint;

  int baseTime;
  boolean faded = false;

  boolean canvasPreview = false;

  String[] shaderFiles = {
    "maritimeVapor_01.glsl",
    "maritimeVapor_02.glsl",
    "maritimeVapor_03.glsl",
    "maritimeVapor_04.glsl",
    "maritimeVapor_05.glsl",
    "maritimeVapor_06.glsl",
    "maritimeVapor_07.glsl"
  };

  String shaderFile;

  PGraphics canvas;
  PShape brush;
  float brushSize;

  float brushColor = 255;

  Content() {
    
    PImage maskImg = loadImage("mask.png");

    canvas = createGraphics((int) totalWidth, (int) totalHeight, P2D);
    canvas.beginDraw();
    canvas.background(0);
    canvas.image(maskImg, 0, 0, totalWidth, totalHeight);  
    canvas.endDraw();

    baseTime = round(random(1.0)*10000);
    
    loadGLSL();

    PVector canvasSize = new PVector(totalWidth, totalHeight);
    shaderPaint.set("canvasSize", canvasSize );
    shaderPaint.set("canvas", canvas);

    brushSize = round(totalWidth*.1);
    //brush = createShape(); //createGraphics((int) brushSize, (int) brushSize, P2D);

    renderBrush();
  }

  void render() {

    if (!calibrating) {
      if (keyPressed) {
        adjustBrushSize(key);
      }

      if (mousePressed) {
        canvas.beginDraw();
        float brushSize = totalWidth*.1;
        canvas.noStroke();
        //canvas.ellipse(cursor.x, cursor.y, brushSize, brushSize);
        //canvas.shapeMode(CENTER);
        canvas.shape(brush, cursor.x, cursor.y);
        canvas.endDraw();
      }
    }


    gfx.beginDraw();

    if (canvasPreview) {
      gfx.image(canvas, 0, 0);

      gfx.resetShader();

      gfx.ellipseMode(CENTER);
      gfx.noFill();
      gfx.strokeWeight(5);
      gfx.stroke(255);
      gfx.ellipse(cursor.x, cursor.y, brushSize, brushSize);

      gfx.stroke(0);
      gfx.ellipse(cursor.x, cursor.y, brushSize-5, brushSize-5);
    } else {
      float localTime = millis()/1000.0 + baseTime;
      shaderPaint.set("time", localTime);

      shaderPaint.set("canvas", canvas);

      gfx.shader(shaderPaint);
      gfx.fill(255);
      gfx.rect(0, 0, totalWidth, totalHeight);
    }

    gfx.endDraw();
  }
  
  void loadGLSL() {
    shaderFile = "shaderPaint_spooky.glsl"; //shaderFiles[shaderFiles.length-1];
    shaderPaint  = loadShader(shaderFile);

    PVector center = new PVector(totalWidth*.5, totalHeight*.5);
    shaderPaint.set("center", center.x, center.y);
    float maxRadius = (totalWidth < totalHeight) ? center.x : center.y;
    shaderPaint.set("maxRadius", maxRadius);
    shaderPaint.set("faded", faded);
  }

  void renderBrush() {
    brush = createShape();

    float brushRadius = brushSize*.5;
    int totalSegments = 100;

    //brush.beginDraw();
    //brush.clear();
    //brush.noStroke();


    //brush.translate(brushRadius, brushRadius);

    brush.beginShape(TRIANGLE_FAN);
    brush.noStroke();

    brush.fill(brushColor, 225*.12 );
    brush.vertex(0, 0);

    for (int i=0; i <= totalSegments; i++) {
      float p = (float )i/totalSegments;
      float angle = p*TWO_PI;
      float x = cos(angle)*brushRadius;  //random(brushSize);
      float y = sin(angle)*brushRadius; //random(brushSize);
      brush.fill(brushColor, 0 );
      brush.vertex(x, y);
    }

    brush.endShape();

    //brush.endDraw();
  }

  void adjustBrushSize(char keyValue) {
    
    float brushSizeIncrement = 5; 
    float brushSizeMinimum = 5;
    
    if (keyValue == '-') {
      brushSize -= brushSizeIncrement;
      if (brushSize < brushSizeMinimum) brushSize = brushSizeMinimum;
      
      renderBrush();
    }
    
    if (keyValue == '=') {
      brushSize += brushSizeIncrement;
      renderBrush();
    }
  }

  void keyPressRelay(char keyValue) {

    println("keyValue: "+keyValue);

    if (keyValue == 'p') canvasPreview = !canvasPreview;

    if (keyValue == 'x') {
      if (brushColor == 255) brushColor = 0;
      else brushColor = 255;

      println("brushColor: "+brushColor);

      renderBrush();
    }
    
    if(keyValue == 'r') {
      loadGLSL();
    }
    
    if(keyValue == 's') {
      canvas.save("data/mask.png");
    }

    //adjustBrushSize(keyValue);
    
    //  println("keyPressRelay: "+keyValue);

    //  switch(keyValue) {
    //  case '1':
    //    shaderFile = shaderFiles[0];
    //    break;
    //  case '2':
    //    shaderFile = shaderFiles[1];
    //    break;
    //  case '3':
    //    shaderFile = shaderFiles[2];
    //    break;
    //  case '4':
    //    shaderFile = shaderFiles[3];
    //    break;
    //  case '5':
    //    shaderFile = shaderFiles[4];
    //    break;
    //  case '6':
    //    shaderFile = shaderFiles[5];
    //    break;
    //  case '7':
    //    shaderFile = shaderFiles[6];
    //    break;
    //  case 'f':
    //    faded = faded ? false : true;
    //    break;
    //  }

    //  maritimeVapor  = loadShader(shaderFile);

    //  PVector center = new PVector(totalWidth*.5, totalHeight*.5);
    //  maritimeVapor.set("center", center.x, center.y);
    //  float maxRadius = (totalWidth < totalHeight) ? center.x : center.y;
    //  maritimeVapor.set("maxRadius", maxRadius);
    //  maritimeVapor.set("faded", faded);
  }
}
