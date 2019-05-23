25::ms => dur T;
50 => int N;     // 聴衆の人数
// .05 => float K;  // 秩序パラメータ：相互作用の強さ
// K / N => float M;
1. => float norm;
float phase[N];
float freq[N];
float v[N];
int msg[N];
float x[N];
float y[N];
"clap.wav" @=> string file;
OscSend xmit;
xmit.setHost("localhost", 1234);

SndBuf s[N];
Pan2 p[N];
Pan2 g => dac;
.5 => g.gain;

"/clap, " => string address;

for (int i; i < N; i++) {
    s[i] => p[i] => g;
    file => s[i].read;
    s[i].samples() => s[i].pos;
    0 => s[i].loop;
    Std.rand2f(.8, 1.2) => s[i].rate;
    Std.rand2f(.01, .05) => s[i].gain;
    Std.rand2f(-1, 1) => p[i].pan;
    Std.rand2f(0, 2 * pi) => phase[i];
    Std.rand2f(.4, .6) => freq[i];
    300.0 + 200*Math.cos(2*pi*i/N) => x[i];
    300.0 + 200*Math.sin(2*pi*i/N) => y[i];
    "i, f, f" +=> address;
}

while (T => now) {
    for (int i; i < N; i++) {
        Std.rand2f(-2.0, 2.0) +=> x[i];
        Std.rand2f(-2.0, 2.0) +=> y[i];
    }
    float sum;
    for (int i; i < N; i++) {
        0 => sum;
        for (int j; j < N; j++) {
            float dx2, dy2, d, kk;
            Math.pow(x[j] - x[i], 2) => dx2;
            Math.pow(y[j] - y[i], 2) => dy2;
            Math.sqrt(dx2+dy2) => d;
            1.0 * d / norm => kk;
            kk / N => float mm;
            Math.sin(phase[j] - phase[i]) * mm => float calc;
            calc +=> sum;
        }
        freq[i] + sum => v[i];
        0 => msg[i];
    }
    xmit.startMsg(address);
    for (int i; i < N; i++) {
        v[i] +=> phase[i];
        if (phase[i] > 2 * pi) {
            2 * pi -=> phase[i];
            0 => s[i].pos;
            1 => msg[i];
        }
        xmit.addInt(msg[i]);
        xmit.addFloat(x[i]);
        xmit.addFloat(y[i]);
    }
}
