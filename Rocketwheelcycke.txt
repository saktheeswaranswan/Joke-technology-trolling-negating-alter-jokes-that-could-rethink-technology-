/*
  ============================================================
       THE DIWALI ENGINEERING LEGEND - PHASE II
       WHEEL-MOUNTED 30-DEGREE ROCKET PROPULSION
       (FEATURING 3D STICKMAN RIDER & ROTATABLE 3D CAMERA)
  ============================================================
*/

import java.util.ArrayList;

// ------------------------------------------------------------
// GLOBAL VARIABLES
// ------------------------------------------------------------

float crankAngle = 0;
float crankSpeed = 0.035f;

float rearWheelAngle = 0;
float frontWheelAngle = 0;

float roadOffset = 0;

float crankLength = 76;
float wheelRadius = 115;

float sceneScale;

// Interactive 3D Camera Rotation Variables
float rotX = -0.15f;
float rotY = 0.0f;
float lastMouseX, lastMouseY;

ArrayList<Spark> sparks = new ArrayList<Spark>();


// ------------------------------------------------------------
// SETUP
// ------------------------------------------------------------

void setup() {
  fullScreen(P3D);
  smooth(4);
  frameRate(60);

  sceneScale = min(
    width / 950.0f,
    height / 720.0f
  );
}


// ------------------------------------------------------------
// MAIN DRAW
// ------------------------------------------------------------

void draw() {
  background(24, 10, 32);

  lights();
  ambientLight(100, 100, 115);
  directionalLight(
    255, 220, 170,
    -0.5f, -1.0f, -0.5f
  );

  // MECHANICAL MOTION
  // Crank spins naturally with the wheels
  crankAngle += crankSpeed; 
  rearWheelAngle -= crankSpeed * 0.7f;
  frontWheelAngle -= crankSpeed * 0.7f;
  roadOffset += 3;

  if (roadOffset > 110) {
    roadOffset = 0;
  }

  // FIRE THE WHEEL-MOUNTED ROCKETS
  fireWheelRockets();

  // MECHANICAL SCENE & ROTATABLE 3D VIEWPORT
  pushMatrix();
  translate(
    width / 2.0f,
    height * 0.57f,
    0
  );

  // Apply User Touch/Mouse Rotations
  rotateX(rotX);
  rotateY(rotY);
  scale(sceneScale);

  drawRoad();
  drawBicycle();
  drawStickman(); // The rider
  updateAndDrawSparks();

  popMatrix();

  drawHUD();
}


// ------------------------------------------------------------
// TOUCH / MOUSE INTERACTION FOR 3D ROTATION
// ------------------------------------------------------------

void mousePressed() {
  lastMouseX = mouseX;
  lastMouseY = mouseY;
}

void mouseDragged() {
  float dx = mouseX - lastMouseX;
  float dy = mouseY - lastMouseY;

  rotY += dx * 0.01f;
  rotX -= dy * 0.01f;

  // Clamp vertical tilt to prevent flipping upside down
  rotX = constrain(rotX, -1.2f, 1.2f);

  lastMouseX = mouseX;
  lastMouseY = mouseY;
}


// ============================================================
// PARTICLE SYSTEM (CONTINUOUS ROCKET FIRE)
// ============================================================

void fireWheelRockets() {
  float[] wheelXs = {-220, 220};
  float[] wheelAngles = {rearWheelAngle, frontWheelAngle};
  
  for (int w = 0; w < 2; w++) {
    float wx = wheelXs[w];
    float wy = 0;
    float wAngle = wheelAngles[w];
    
    // 12 Rockets per wheel (360 / 30 degrees = 12)
    for (int i = 0; i < 12; i++) {
      float theta = wAngle + radians(i * 30);
      
      // Control spark density to prevent lag (random emission)
      if (random(1) < 0.45f) {
        // Calculate absolute 3D world coordinates for the fuse of the rocket
        float rocketScale = 0.35f;
        float effectiveRadius = wheelRadius + 6;
        float localFuseY = 65 * rocketScale; // Fuse position scaled down
        
        float fuseX = wx + effectiveRadius * cos(theta) - localFuseY * sin(theta);
        float fuseY = wy + effectiveRadius * sin(theta) + localFuseY * cos(theta);
        
        // Stagger Z-depth slightly like they are tied outside the spokes
        float fuseZ = (i % 2 == 0) ? 12 : -12;
        
        // Thrust direction points exactly out of the fuse (tangential)
        float dirX = -sin(theta);
        float dirY = cos(theta);
        
        float speed = random(4, 9);
        float vx = dirX * speed + random(-1.5f, 1.5f);
        float vy = dirY * speed + random(-1.5f, 1.5f);
        
        // Generate glowing sparks
        sparks.add(new Spark(fuseX, fuseY, fuseZ, vx, vy, random(-1, 1), random(20, 40), random(2, 4), false));
        
        // Occasional smoke trail
        if (random(1) < 0.15f) {
           sparks.add(new Spark(fuseX, fuseY, fuseZ, vx*0.4f, vy*0.4f, 0, random(30, 55), random(4, 9), true));
        }
      }
    }
  }
}


// ============================================================
// STICKMAN & INVERSE KINEMATICS
// ============================================================

void drawStickman() {
  pushStyle();
  strokeJoin(ROUND);
  strokeCap(ROUND);
  noFill();

  // STICKMAN CORE POSITIONS
  PVector hip = new PVector(-100, -175, 0);
  PVector shoulder = new PVector(-50, -300, 0);
  PVector head = new PVector(-35, -360, 0);

  // 1. SPINE
  stroke(210, 215, 220);
  strokeWeight(18);
  line(hip.x, hip.y, hip.z, shoulder.x, shoulder.y, shoulder.z);

  // 2. HEAD & VISOR
  pushMatrix();
  translate(head.x, head.y, head.z);
  fill(210, 215, 220);
  noStroke();
  sphereDetail(12);
  sphere(25);
  
  // Glowing Visor
  fill(255, 120, 30);
  translate(14, -2, 0); 
  sphereDetail(10);
  sphere(16);
  popMatrix();

  // 3. CROSSBARS
  stroke(210, 215, 220);
  strokeWeight(16);
  line(shoulder.x, shoulder.y, -30, shoulder.x, shoulder.y, 30);
  line(hip.x, hip.y, -20, hip.x, hip.y, 20);

  // 4. ARMS & LEGS SETUP
  PVector leftShoulder = new PVector(shoulder.x, shoulder.y, -30);
  PVector rightShoulder = new PVector(shoulder.x, shoulder.y, 30);
  PVector leftHip = new PVector(hip.x, hip.y, -20);
  PVector rightHip = new PVector(hip.x, hip.y, 20);

  // Target Handlebar Positions
  float hx_grip = 140; 
  float hy_grip = -205; 
  PVector leftHand = new PVector(hx_grip, hy_grip, -45);
  PVector rightHand = new PVector(hx_grip, hy_grip, 45);

  // Target Pedal Positions
  float cx = -15;
  float cy = 0;
  PVector leftPedal = new PVector(cx + cos(crankAngle)*crankLength, cy + sin(crankAngle)*crankLength, -25);
  PVector rightPedal = new PVector(cx + cos(crankAngle + PI)*crankLength, cy + sin(crankAngle + PI)*crankLength, 25);

  // SOLVE KINEMATICS (IK)
  PVector leftElbow = solveIK(leftShoulder, leftHand, 115, 115, 1);
  PVector rightElbow = solveIK(rightShoulder, rightHand, 115, 115, 1);
  PVector leftKnee = solveIK(leftHip, leftPedal, 135, 135, -1);
  PVector rightKnee = solveIK(rightHip, rightPedal, 135, 135, -1);

  // 5. DRAW ARMS
  stroke(210, 215, 220);
  strokeWeight(14);
  line(leftShoulder.x, leftShoulder.y, leftShoulder.z, leftElbow.x, leftElbow.y, leftElbow.z);
  line(leftElbow.x, leftElbow.y, leftElbow.z, leftHand.x, leftHand.y, leftHand.z);
  line(rightShoulder.x, rightShoulder.y, rightShoulder.z, rightElbow.x, rightElbow.y, rightElbow.z);
  line(rightElbow.x, rightElbow.y, rightElbow.z, rightHand.x, rightHand.y, rightHand.z);

  // 6. DRAW LEGS
  stroke(180, 185, 190);
  strokeWeight(16);
  line(leftHip.x, leftHip.y, leftHip.z, leftKnee.x, leftKnee.y, leftKnee.z);
  line(leftKnee.x, leftKnee.y, leftKnee.z, leftPedal.x, leftPedal.y, leftPedal.z);
  line(rightHip.x, rightHip.y, rightHip.z, rightKnee.x, rightKnee.y, rightKnee.z);
  line(rightKnee.x, rightKnee.y, rightKnee.z, rightPedal.x, rightPedal.y, rightPedal.z);

  // 7. ROBOTIC JOINTS
  noStroke();
  fill(40, 45, 50);
  sphereDetail(8);
  drawJoint(leftElbow, 11);
  drawJoint(rightElbow, 11);
  drawJoint(leftKnee, 13);
  drawJoint(rightKnee, 13);

  popStyle();
}

void drawJoint(PVector pos, float r) {
  pushMatrix();
  translate(pos.x, pos.y, pos.z);
  sphere(r);
  popMatrix();
}

PVector solveIK(PVector start, PVector end, float l1, float l2, int bendDir) {
  float dXY = dist(start.x, start.y, end.x, end.y);
  dXY = max(dXY, abs(l1 - l2) + 0.1f);
  dXY = min(dXY, l1 + l2 - 0.1f);

  float a = atan2(end.y - start.y, end.x - start.x);
  
  float cosBeta = (l1*l1 + dXY*dXY - l2*l2) / (2.0f * l1 * dXY);
  cosBeta = max(-1.0f, min(1.0f, cosBeta));
  float beta = acos(cosBeta);

  float jointAngle = a + (beta * bendDir);
  float jointX = start.x + cos(jointAngle) * l1;
  float jointY = start.y + sin(jointAngle) * l1;
  float jointZ = (start.z + end.z) / 2.0f;

  return new PVector(jointX, jointY, jointZ);
}


// ============================================================
// ROAD
// ============================================================

void drawRoad() {
  pushStyle();
  stroke(100, 85, 90);
  strokeWeight(3);
  line(-600, 160, 0, 600, 160, 0);

  stroke(255, 170, 40);
  strokeWeight(4);

  for (int i = -8; i < 9; i++) {
    float x = i * 110 - roadOffset;
    line(x, 180, 0, x + 50, 180, 0);
  }
  popStyle();
}


// ============================================================
// BICYCLE ASSEMBLY
// ============================================================

void drawBicycle() {
  float rx = -220;
  float fx = 220;
  float wy = 0;
  float cx = -15;
  float cy = 0;
  float sx = -100;
  float sy = -155;
  float hx = 130;
  float hy = -140;

  // WHEELS (Now containing rockets)
  drawWheel(rx, wy, rearWheelAngle);
  drawWheel(fx, wy, frontWheelAngle);

  // BICYCLE FRAME
  pushStyle();
  stroke(15, 15, 20);
  strokeWeight(13);

  line(rx, wy, 0, sx, sy, 0);
  line(sx, sy, 0, cx, cy, 0);
  line(cx, cy, 0, rx, wy, 0);
  line(sx, sy, 0, hx, hy, 0);
  line(hx, hy, 0, cx, cy, 0);

  // FRONT FORK
  stroke(170, 175, 180);
  strokeWeight(9);
  line(hx, hy, 0, fx, wy, 0);

  // SEAT POST
  stroke(150);
  strokeWeight(10);
  line(sx, sy, 0, sx, sy-35, 0);

  // SEAT
  stroke(10);
  strokeWeight(22);
  line(sx-40, sy-38, 0, sx+40, sy-38, 0);

  // 3D HANDLEBAR
  stroke(170);
  strokeWeight(10);
  line(hx, hy, 0, hx+10, hy-65, 0);

  strokeWeight(13);
  line(hx+10, hy-65, -55, hx+10, hy-65, 55); 

  // CRANK ASSEMBLY
  drawCrankAssembly(cx, cy);

  popStyle();
}


// ============================================================
// BICYCLE WHEEL WITH 30-DEGREE MOUNTED ROCKETS
// ============================================================

void drawWheel(float x, float y, float angle) {
  pushMatrix();
  translate(x, y, 0);
  rotate(angle);

  pushStyle();
  noFill();

  // BLACK TYRE
  stroke(10);
  strokeWeight(17);
  ellipse(0, 0, wheelRadius*2, wheelRadius*2);

  // METAL RIM
  stroke(190, 200, 205);
  strokeWeight(5);
  ellipse(0, 0, wheelRadius*1.9f, wheelRadius*1.9f);

  // SPOKES
  stroke(170, 180, 190);
  strokeWeight(2);
  for (int i = 0; i < 24; i++) {
    float a = TWO_PI * i / 24.0f;
    line(0, 0, 0, cos(a)*wheelRadius, sin(a)*wheelRadius, 0);
  }

  // 12 ROCKETS TIED TO THE WHEEL (Every 30 Degrees)
  for (int i = 0; i < 12; i++) {
    float rocketAngle = radians(i * 30);
    pushMatrix();
    rotate(rocketAngle); // Orient along radius
    
    // Translate tangentially to rim and slightly offset Z so they don't hit the frame
    float zOffset = (i % 2 == 0) ? 12 : -12;
    translate(wheelRadius + 6, 0, zOffset);
    
    // Scale down to fit 12 securely around the rim
    scale(0.35f);
    
    // Draw the active rocket
    drawRocketProp(true); 
    popMatrix();
  }

  // HUB
  fill(180);
  stroke(40);
  ellipse(0, 0, 24, 24);

  popStyle();
  popMatrix();
}


// ============================================================
// STANDARD CRANK (NO ROCKETS HERE ANYMORE)
// ============================================================

void drawCrankAssembly(float cx, float cy) {
  pushMatrix();
  translate(cx, cy, 0);

  // CENTRAL CRANK HUB
  fill(150);
  stroke(30);
  strokeWeight(3);
  ellipse(0, 0, 45, 45);

  // LEFT PEDAL
  drawPedal(crankAngle, -25);
  // RIGHT PEDAL
  drawPedal(crankAngle + PI, 25);

  popMatrix();
}

void drawPedal(float angle, float zDepth) {
  float px = cos(angle) * crankLength;
  float py = sin(angle) * crankLength;

  pushMatrix();
  translate(px, py, zDepth);

  // CRANK ARM
  pushMatrix();
  rotate(angle);
  stroke(180, 185, 195);
  strokeWeight(12);
  line(-crankLength, 0, 0, 0, 0, 0);

  // PEDAL BAR
  stroke(255, 180, 40);
  strokeWeight(14);
  line(-22, 0, 0, 22, 0, 0);
  popMatrix();
  
  popMatrix();
}


// ============================================================
// CUSTOM ROCKET CYLINDER
// ============================================================

void drawCylinderY(float radius, float h, int sides) {
  float halfH = h / 2.0f;
  beginShape(QUAD_STRIP);
  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;
    float x = cos(a) * radius;
    float z = sin(a) * radius;
    normal(cos(a), 0, sin(a));
    vertex(x, -halfH, z);
    vertex(x, halfH, z);
  }
  endShape();
  beginShape(TRIANGLE_FAN);
  vertex(0, -halfH, 0);
  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;
    vertex(cos(a) * radius, -halfH, sin(a) * radius);
  }
  endShape();
  beginShape(TRIANGLE_FAN);
  vertex(0, halfH, 0);
  for (int i = sides; i >= 0; i--) {
    float a = TWO_PI * i / sides;
    vertex(cos(a) * radius, halfH, sin(a) * radius);
  }
  endShape();
}

void drawConeY(float radius, float height, int sides) {
  float baseY = 0;
  float tipY = -height;
  beginShape(TRIANGLE_FAN);
  vertex(0, tipY, 0);
  for (int i = 0; i <= sides; i++) {
    float a = TWO_PI * i / sides;
    vertex(cos(a) * radius, baseY, sin(a) * radius);
  }
  endShape();
  beginShape(TRIANGLE_FAN);
  vertex(0, baseY, 0);
  for (int i = sides; i >= 0; i--) {
    float a = TWO_PI * i / sides;
    vertex(cos(a) * radius, baseY, sin(a) * radius);
  }
  endShape();
}

void drawRocketBands(float y, float radius, float thickness) {
  pushStyle();
  noFill();
  stroke(255, 215, 100);
  strokeWeight(thickness);
  ellipse(0, y, radius*2, radius*2);
  popStyle();
}

void drawWavyRocketStripes() {
  pushStyle();
  noFill();
  stroke(225, 65, 35);
  strokeWeight(3);
  for (int row = 0; row < 8; row++) {
    beginShape();
    for (int i = 0; i <= 100; i++) {
      float a = TWO_PI * i / 100.0f;
      float y = -30 + row * 9 + sin(a * 5) * 3.5f;
      float r = 21;
      vertex(cos(a) * r, y, sin(a) * r);
    }
    endShape();
  }
  popStyle();
}

void drawRocketStick() {
  pushStyle();
  stroke(230, 235, 245);
  strokeWeight(12);
  line(0, 38, 0, 0, 125, 0);
  stroke(210, 35, 35);
  strokeWeight(6);
  for (int i = 0; i < 8; i++) {
    float y = 44 + i * 11;
    line(-5, y, 0, 5, y + 7, 0);
  }
  popStyle();
}

void drawRocketIgnition(boolean active) {
  pushStyle();
  stroke(220, 190, 110);
  strokeWeight(4);
  line(18, 35, 0, 28, 45, 0);

  noStroke();
  fill(255, 160, 20);
  sphereDetail(8);
  pushMatrix();
  translate(28, 45, 0);
  sphere(4);
  popMatrix();

  if (active) {
    fill(255, 170, 20, 180);
    pushMatrix();
    translate(0, 52, 0);
    sphereDetail(8);
    sphere(11);
    popMatrix();

    fill(255, 230, 90, 200);
    pushMatrix();
    translate(0, 65, 0);
    sphere(6);
    popMatrix();
  }
  popStyle();
}


// ============================================================
// COMPLETE DIWALI ROCKET GEOMETRY
// ============================================================

void drawRocketProp(boolean active) {
  pushStyle();

  // ROCKET CYLINDRICAL BODY
  pushMatrix();
  noStroke();
  fill(40, 115, 30);
  drawCylinderY(22, 82, 24);

  // RED CONICAL NOSE
  pushMatrix();
  translate(0, -41, 0);
  fill(230, 35, 30);
  drawConeY(23, 58, 28);
  popMatrix();

  // GREEN NECK BAND
  fill(35, 115, 35);
  pushMatrix();
  translate(0, -36, 0);
  drawCylinderY(22, 10, 24);
  popMatrix();

  // GOLDEN DECORATIVE BANDS
  drawRocketBands(-28, 22, 3);
  drawRocketBands(-20, 22, 3);
  drawRocketBands(-12, 22, 3);
  drawRocketBands(30, 22, 3);
  drawRocketBands(36, 22, 3);

  // GOLDEN DOTTED BAND
  pushStyle();
  noStroke();
  fill(255, 215, 100);
  for (int i = 0; i < 20; i++) {
    float a = TWO_PI * i / 20.0f;
    pushMatrix();
    translate(cos(a) * 22, -17, sin(a) * 22);
    sphereDetail(5);
    sphere(1.8f);
    popMatrix();
  }
  popStyle();

  drawWavyRocketStripes();
  drawRocketStick();
  drawRocketIgnition(active);

  popMatrix();
  popStyle();
}


// ============================================================
// PARTICLE CLASS
// ============================================================

class Spark {
  PVector position;
  PVector velocity;
  float life, maxLife, particleSize;
  boolean smoke;

  Spark(float x, float y, float z, float vx, float vy, float vz, float lifespan, float size, boolean isSmoke) {
    position = new PVector(x, y, z);
    velocity = new PVector(vx, vy, vz);
    life = lifespan;
    maxLife = lifespan;
    particleSize = size;
    smoke = isSmoke;
  }

  void update() {
    position.add(velocity);
    velocity.mult(smoke ? 0.98f : 0.97f);

    if (smoke) velocity.y -= 0.035f;
    else velocity.y += 0.045f;
    
    life--;
  }

  void display() {
    pushStyle();
    float alpha = 255.0f * (life / maxLife);

    if (smoke) {
      noStroke();
      fill(160, 145, 155, alpha * 0.45f);
      pushMatrix();
      translate(position.x, position.y, position.z);
      sphereDetail(4);
      sphere(particleSize * (2.0f - (life / maxLife)));
      popMatrix();
    } else {
      stroke(255, 175, 35, alpha);
      strokeWeight(particleSize);
      point(position.x, position.y, position.z);

      stroke(255, 240, 130, alpha);
      line(position.x, position.y, position.z, position.x - velocity.x*2, position.y - velocity.y*2, position.z - velocity.z*2);
    }
    popStyle();
  }

  boolean dead() { return life <= 0; }
}

void updateAndDrawSparks() {
  for (int i = sparks.size()-1; i >= 0; i--) {
    Spark s = sparks.get(i);
    s.update();
    s.display();
    if (s.dead()) sparks.remove(i);
  }
}


// ============================================================
// HUD
// ============================================================

void drawHUD() {
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  pushStyle();
  textAlign(CENTER, CENTER);

  fill(255);
  textSize(22);
  text("THE DIWALI ENGINEERING LEGEND (PHASE II)", width/2.0f, 35);

  textSize(15);
  text("DRAG SCREEN TO ROTATE 3D VIEW", width/2.0f, 65);

  fill(255, 190, 40);
  textSize(17);
  text("WHEEL ROCKETS: 24 ACTIVE", width/2.0f, height-90);

  fill(100, 240, 140);
  text("LIVE PARTICLE COUNT: " + sparks.size(), width/2.0f, height-60);

  fill(255);
  textSize(14);
  text("30-DEGREE TANGENTIAL RIM PROPULSION", width/2.0f, height-30);

  popStyle();
  hint(ENABLE_DEPTH_TEST);
}
