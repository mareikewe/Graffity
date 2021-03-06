// läuft Pixel für Pixel das Bild ab und ordnet gleichfarbige Pixel in ein Blob
// misst Entfernung zw. gleichen Pixel und legt neuen Blob an, wenn gleichfarbener Pixel zu weit von vorigem weg

class Blob{
  // Anfang des Blobs
  float minX;
  float minY;
  
  // Ende des Blobs, quasi W und H
  float maxX;
  float maxY;
  
  int timer = 100; // steuert, dass blob nur gelöscht wird, wenn er inaktiv ist
  
  int blobId = 0;
  
  boolean taken = false;
  
  ArrayList<PVector> points;
  
  Blob(float x, float y) {
    this.minX = x;
    this.minY = y;
    this.maxX = x;
    this.maxY = y;
    this.points = new ArrayList<PVector>();
    points.add(new PVector(x, y));
  }
  
  void show() {
    stroke(0);
    fill(255);
    strokeWeight(2);
    rectMode(CORNERS);
    rect(minX, minY, maxX, maxY);
    
    textAlign(CENTER);
    textSize(64);
    fill(0);
    text(blobId, minX + (maxX - minX)* 0.5, maxY - 10); // Center of Rect
    textSize(32);
    text(timer, minX + (maxX - minX)* 0.5, minX - 10);
  }
  
  void add(float x, float y) {
    // Hoehe der Variablen vergleichen und Minimum bzw. Maximum herausfinden
    minX = min(minX, x);
    minY = min(minY, y);
    maxX = max(maxX, x);
    maxY = max(maxY, y);
  }
  
  void become(Blob other) {
    minX = other.minX;
    maxX = other.maxX;
    minY = other.minY;
    maxY = other.maxY;
  }
  
  float size() {
    return (maxX - minX) * (maxY - minY);
  }
  
  PVector getCenter() { // Center of Blob
    float x = (maxX - minX) * 0.5 + minX;
    float y = (maxY - minY) * 0.5 + minY;
    return new PVector(x, y);
  }
    
  boolean isNear(float x, float y) {
    
    // nächst gelegener Pixel des Blobs suchen
    float cx = max(min(x, maxX), minX);
    float cy = max(min(y, maxY), minY);
    
    // Zentrum der Blobs herausfinden
    // float cx = (minX + maxX) / 2; 
    // float cy = (minY + maxY) / 2; 
  
    // Distanz
    float d = distSq(cx, cy, x, y);
    
    if (d < distThreshold*distThreshold) {
      return true;
    } else {
      return false;
    }
  }
}
