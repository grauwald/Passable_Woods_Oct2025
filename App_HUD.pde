class HUD {

  float margin = 24;
  float fontSize = 24;

  HUD() {
  }

  void render() {
    push();

    textSize(fontSize);
    fill(255);

    textAlign(LEFT, TOP);
    text(round(frameRate)+" FPS", margin, margin );

    if (RECORD) {
      textAlign(RIGHT, TOP);
      text(frameCount+"/"+TOTAL_FRAMES, width-margin, margin );

      String percent = round((float(frameCount)/TOTAL_FRAMES)*100)+"%";
      text(percent, width-margin, margin*2 );
    }

    pop();
  }
}
