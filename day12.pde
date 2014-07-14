import geomerative.*;

import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;

import java.util.Calendar;

import gifAnimation.*;

GifMaker gifExport;
float index, x, y, size, ellipseX, ellipseY;

Minim minim;
AudioPlayer song;
BeatDetect beat;
BeatListener bl;
ArrayList balls = new ArrayList();

RFont font;
String strings[] = {"Peace"};
String str;
RPoint[] myPoints; 
RGroup myGroup;

void setup()
{
  size(640, 640);
  // always start Minim before you do anything with it
  minim = new Minim(this);
  frameRate( 30 );
  smooth();
  song = minim.loadFile("song.mp3", 1024);

  beat = new BeatDetect(song.bufferSize(), song.sampleRate());

  beat.setSensitivity(0);
  bl = new BeatListener(beat, song); 

  RG.init(this); 
  font = new RFont("PFBulletinSansPro-Bold.ttf", 100, CENTER);

  song.play();
  noStroke();
  
  frameRate(15);
  gifExport = new GifMaker(this, "visualizer.gif");
  gifExport.setRepeat(0); // make it an "endless" animation
  gifExport.setDelay(1000/12);  //12fps in ms
}

void draw()
{
  fill(0, 0, 0, 80);
  rect(0, 0, width, height);
  // use the mix buffer to draw the waveforms.
  // because these are MONO files, we could have used the left or right buffers and got the same data
  boolean kick = beat.isKick();
  boolean hat = beat.isHat();
  boolean snare = beat.isSnare();

  str = strings[(int)(random(strings.length))];

  color col = drawColor();

  if (snare)
  {
    for ( int j = 0; j < abs(song.mix.level() * 100); j++ )
    {
      float x = j*20;
      for (int i = 0; i < abs(song.mix.level()*70); i++)
      {
        fill(col);
        rect(x, i, song.mix.get(0)*70, song.mix.get(0)*70);
        rect(x, height - i, song.mix.get(0)*70, song.mix.get(0)*70);
        rect(width - i, x, song.mix.get(0)*70, song.mix.get(0)*70);
        rect(i, x, song.mix.get(0)*70, song.mix.get(0)*70);
      }
    }
  }

  if (kick) {
    ellipse(width/2, height/2, song.mix.get(0)*400, song.mix.get(0)*400);
  }

  if (hat) {
    stroke(drawColor());

    for ( int j = 0; j < abs(song.mix.level() * 1000); j+=10 )
    {
      float x = j*20;
      float y = random(height);
      for (int i = 0; i < abs(song.mix.level()*70); i++)
      {
        fill(col);
        ellipse(x, y, song.mix.get(0)*20, song.mix.get(0)*20);
      }
    }
  }

  if (beat.isRange(2, 4, 2)) {
    triangle(width/2, height/4 + song.mix.level()*50, width/1.5 - song.mix.level()*50, height/1.5, width/3 + song.mix.level()*50, height/1.5);
    fill(drawColor());

    if (str.length() > 0) {
      
      RCommand.setSegmentLength(map(song.mix.level()*3000, width, 0, 10, 100));
      RCommand.setSegmentator(RCommand.UNIFORMLENGTH);
      
      RGroup myGroup = font.toGroup(str); 
      myGroup = myGroup.toPolygonGroup();
      RPoint[] myPoints = myGroup.getPoints();
      
      pushMatrix();
      translate(width/2, height/1.6);
      rotate(random(-PI/90, PI/90));
      noFill();
      beginShape();
      for (int i=0; i<myPoints.length; i++) { 
        curveVertex(myPoints[i].x, myPoints[i].y);
      }
      endShape();
      popMatrix();

      noFill();
    }

    if (beat.isRange(1, 4, 2)) {
      for (int i = 0; i <= 200; i+=20) {
        ellipse(i, height/2, song.mix.get(0)*i, song.mix.get(0)*i);
      }
      for (int i = 0; i <= 200; i+=20) {
        ellipse(width - i, height/2, song.mix.get(0)*i, song.mix.get(0)*i);
      }
    }

    if (beat.isRange(5, 8, 2)) {
      for (int i = 0; i <= 200; i+=40) {
        ellipse(width/2, i, song.mix.get(0)*i, song.mix.get(0)*i);
      }
      for (int i = 0; i <= 200; i+=20) {
        ellipse(width/2, height - i, song.mix.get(0)*i, song.mix.get(0)*i);
      }
    }
  }
  
  gifExport.addFrame();

  if (frameCount == 120) gifExport.finish(); 
  println(frameCount);

}

void stop()
{
  // always close Minim audio classes when you are done with them
  song.close();
  minim.stop();

  super.stop();
}

class BeatListener implements AudioListener
{
  private BeatDetect beat;
  private AudioPlayer source;

  BeatListener(BeatDetect beat, AudioPlayer source)
  {
    this.source = source;
    this.source.addListener(this);
    this.beat = beat;
  }

  void samples(float[] samps)
  {
    beat.detect(source.mix);
  }

  void samples(float[] sampsL, float[] sampsR)
  {
    beat.detect(source.mix);
  }
}

color drawColor() {

  color c1 = color(random(50, 200), random(20, 120), random(20, 30));
  color c2 = color(random(50, 80), random(20, 100), random(60, 100));
  color c3 = color(random(50, 80), random(20, 100), random(20, 100));

  float num = random(100) / random(100);
  println(num);

  if (num > 1) {
    return c1;
  }
  else if (num >=3) {
    return c2;
  }
  else {
    return c3;
  }
}

void keyReleased() {
  if (key == 's' || key == 'S') saveFrame(timestamp()+"_##.png");
}

// timestamp
String timestamp() {
  Calendar now = Calendar.getInstance();
  return String.format("%1$ty%1$tm%1$td_%1$tH%1$tM%1$tS", now);
}



