float spieler_x;
float spieler_y;
float ball_x;
float ball_y;
float ball_geschwindigkeit_x;
float ball_geschwindigkeit_y;

int runde;

void setup(){
  spieler_x = 20;
  spieler_y = 60;
  ball_x = 400;
  ball_y = 300;
  ball_geschwindigkeit_x = -4;
  ball_geschwindigkeit_y = 0;
  runde = 0;
  size(800, 600);
  rectMode(CENTER);
}

void draw(){
  background(0);
  rect(spieler_x, spieler_y, 20, 100);
  rect(ball_x, ball_y, 10, 10);
  if(keyPressed){
    if(keyCode == DOWN){
      if(spieler_y < 550){
      spieler_y = spieler_y + 5;
     }
   }
   if(keyCode == UP){
     if(spieler_y > 50){
       spieler_y = spieler_y - 5;
     }
   }
  }
  ball_x = ball_x + ball_geschwindigkeit_x;
  ball_y = ball_y + ball_geschwindigkeit_y;
  
  if(ball_x < 30){
    if(ball_y < (spieler_y + 55) && ball_y > (spieler_y - 55)){
      ball_geschwindigkeit_x = (-ball_geschwindigkeit_x) +1;
      ball_geschwindigkeit_y = ball_geschwindigkeit_y - (spieler_y - ball_y) * 0.1;
      runde = runde + 1;
    }else{
      ball_x = 400;
      ball_y = 300;
      ball_geschwindigkeit_x = -4;
      ball_geschwindigkeit_y = 0;
      runde = 0;
  }
  }
  if(ball_y > 595 || ball_y < 5){
    ball_geschwindigkeit_y = -ball_geschwindigkeit_y;
  }
  if(ball_x > 795){
  ball_geschwindigkeit_x = -ball_geschwindigkeit_x;
  }
  text("Runde: " + runde, 700, 20);
}