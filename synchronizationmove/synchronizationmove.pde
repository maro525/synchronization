// import processing.sound.*;
import oscP5.*;

// ArrayList<Thing> things = new ArrayList<Thing>();
ArrayList<Circle> things = new ArrayList<Circle>();
int N = 50;
float size = 15.0;

OscP5 oscP5;
String address = "/clap";
int receivePort = 1234;


void setup() {
    size(600, 600);
    background(0);

    for(int i=0; i < N; i++) {
        float px = 300 + 200 * cos(TWO_PI*i/N);
        float py = 300 + 200 * sin(TWO_PI*i/N);
        things.add(new Circle(px, py, size));
    }


    frameRate(30);

    oscP5 = new OscP5(this, receivePort);

}

void draw() {
    background(10);
    fill(100);
    rect(600, 0, 600, 600);
    drawthings();
}

// void updatethings() {
//     int clap_n = 0;
//     for(int i=0; i<things.size(); i++) {
//         for(int j=0; j<things.size(); j++) {
//             things.get(i).addAffect(things.get(j).phase);
//         }
//         things.get(i).update();
//         if(things.get(i).phase < 0.8 && !things.get(i).bPlay){
//             clap_n += 1;
//             things.get(i).bPlay = true;
//         }
//     }
//     if(clap_n != 0){
//         float amp_f = 10.0*(float)clap_n / (float)N;
//         int amp_i = ceil(amp_f);
//         float amp = (float)amp_i / 10.0;
//         clap.amp(amp);
//         clap.play();
//     }
// }

void drawthings() {
    for(int i=0; i<things.size(); i++) {
        things.get(i).draw();
    }
}

void oscEvent(OscMessage message) {
    if(message.checkAddrPattern(address)) {
        for(int i=0; i<N; i++) {
            int m = message.get(i*3).intValue();
            things.get(i).setStatus(m);
            float x = message.get(i*3+1).floatValue();
            float y = message.get(i*3+2).floatValue();
            things.get(i).setPos(x, y);
            println("recv", i, m, x, y);
        }
    }
}
