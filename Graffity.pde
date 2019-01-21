import processing.video.*;

Capture cam;

int blobCounter = 0;

color trackColor;
float clrThreshold = 25; // wert um den farbe abweichen darf
float distThreshold = 25; // wert um den distanz abweichen darf

int maxLife = 200;

// History-Liste of Blobs
ArrayList<Blob> blobs = new ArrayList<Blob>();

// ellipsenbewegung smoother machen
float lerpX = 0;
float lerpY = 0;

void setup() {
  size(1200, 800);

  String[] cameras = Capture.list();
  
  trackColor = color(243, 120, 35);
  
  // Available Kameras auflisten und starten
  if (cameras.length == 0) {
    println("There are no cameras available for capture.");
    exit();
  } else {
    println("Available cameras:");
    for (int i = 0; i < cameras.length; i++) {
      println(cameras[i]);
    }
    
    // The camera can be initialized directly using an 
    // element from the array returned by list():
    cam = new Capture(this, cameras[0]);
    cam.start();     
  }    
  
}

// An event for when a new frame is available
void captureEvent(Capture cam) {
  // Read img from cam
  cam.read();
}

void keyPressed() {
  if(key == 'a') distThreshold+=5;
  else if (key == 'y') distThreshold-=5;
  
  if(key == 's') clrThreshold+=5;
  else if (key == 'x') clrThreshold-=5;
}

void draw() {
  
  cam.loadPixels();
  image(cam, 0, 0);
  
  // Aktuelle Blobs, jeden Frame neues Array initialisieren
  ArrayList<Blob> currentBlobs = new ArrayList<Blob>();

  // jeden Pixel abfahren
  for (int x = 0; x < cam.width; x++) {
    for (int y = 0; y < cam.height; y++) {
      
      int loc = x + y * cam.width; // aktuelles Pixel, pixel fortlaufend nr. verteilt. hier wird diese errechnet
      // current color
      color currentColor = cam.pixels[loc]; 
      float r1 = red(currentColor);
      float g1 = green(currentColor);
      float b1 = blue(currentColor);
      float r2 = red(trackColor);
      float g2 = green(trackColor);
      float b2 = blue(trackColor);

      // Using euclidean distance to compare colors
      float d = distSq(r1, g1, b1, r2, g2, b2); // We are using the dist( ) function to compare the current color with the color we are tracking.
      
      // was passiert, wenn Farbe von Pixel in erlaubtem Farbwert ist?
      if (d < clrThreshold*clrThreshold) {
        
        boolean found = false;
        for (Blob b : currentBlobs) { // vorhandene Blobs absuchen, ob Pixel dazugehört
          if(b.isNear(x,y)) {
            b.add(x, y);
            found = true;
            break;
          }
        }
        
        if (!found) {
          Blob b = new Blob(x,y);
          currentBlobs.add(b);
        }        
      }
    }
  }
  
  // kleine Blobs loeschen
  for (int i = currentBlobs.size()-1; i >= 0; i-- ) {
    if (currentBlobs.get(i).size() < 500) {
      currentBlobs.remove(i);
    }
  }
  
  // MATCH currentBlobs with blobs!
  
  // Possibility #1
  // ToDo: kein Matching, nur adden in History of Blobs (Array: blobs)
  if (blobs.isEmpty() && currentBlobs.size() > 0) {
    println("Adding Blobs!");
    for (Blob b : currentBlobs) {
      b.blobId = blobCounter; // bei adden, ID vergeben
      blobs.add(b);
      blobCounter++;
    }
  } else if (blobs.size() <= currentBlobs.size()) { 
    // Possibility #2 - match whatever blobs you can match
    for (Blob b : blobs) {
      float recordDist = 1000;
      Blob matched = null;
      for (Blob cb : currentBlobs) {
        PVector centerB = b.getCenter();
        PVector centerCB = cb.getCenter();
        float d = PVector.dist(centerB, centerCB);
        if (d < recordDist && !cb.taken) {
          recordDist = d;
          matched = cb;
        }
      }
      matched.taken = true;
      b.become(matched); // b wird matched Blob
    }
  }
  // Possibility #3 - look at the blobs that i have and see which blobs are left over
  else if (blobs.size() > currentBlobs.size()) {
    
    for (Blob b : blobs) { // bevor irgendwas passiert, taken bei allen Blobs auf false
      b.taken = false;
    }
    
    for (Blob cb : currentBlobs) {
      float recordDist = 1000;
      Blob matched = null;
      for (Blob b : blobs) {
        PVector centerB = b.getCenter();
        PVector centerCB = cb.getCenter();
        float d = PVector.dist(centerB, centerCB);
        if (d < recordDist && !b.taken) {
          recordDist = d;
          matched = b;
        }
      }
      if (matched != null) {
        matched.taken = true;
        matched.become(cb);
      }
      
    }
    
    for (int i = blobs.size()-1; i >= 0; i--) {
        Blob b = blobs.get(i);
        if (!b.taken) {
          blobs.remove(i);
        }
    }
  }
  
  for (Blob b : blobs) {
    b.show();
  }
  
  textAlign(RIGHT);
  textSize(32);
  fill(0);
  text(blobs.size(), width - 10, 40);
  text(currentBlobs.size(), width - 10, 80);

  //text("distance threshold: " + distThreshold, width-10, 25);
  //text("color threshold: " + clrThreshold, width-10, 50);

  
  // NOCH EINBAUEN IN BLOBS
  /*if (count > 0) { 
    motionX = averageX / count;
    motionY = averageY / count;
  }
  
  lerpX = lerp(lerpX, motionX, 0.1);
  lerpY = lerp(lerpY, motionY, 0.1);
  
  // Draw a circle at the tracked pixel 
  fill(255);
  strokeWeight(4.0);
  stroke(0);
  ellipse(lerpX, lerpY, 24, 24);*/
  
}

float distSq(float x1, float y1, float x2, float y2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1);
  return d;
}

float distSq(float x1, float y1, float z1, float x2, float y2, float z2) {
  float d = (x2-x1)*(x2-x1) + (y2-y1)*(y2-y1) + (z2-z1)*(z2-z1);
  return d;
}

void mousePressed() {
  // Save color where the mouse is clicked in trackColor variable
  int loc = mouseX + mouseY * cam.width;
  trackColor = cam.pixels[loc];
}
