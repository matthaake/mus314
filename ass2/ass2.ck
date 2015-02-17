.5::second => dur quarternote;


[60, 62, 64, 67, 67, 69, 69, 72, 76, 84] @=> int mynotes[];

int dice;
int melody1[8];
for (0 => int i; i < melody1.size(); i++) {
    Math.random2(0, mynotes.size()-1) => dice;
    mynotes[dice] => melody1[i];
}

int melody2[16];
for (0 => int i; i < melody2.size(); i++) {
    Math.random2(0, mynotes.size()-1) => dice;
    mynotes[dice] => melody2[i];
}



spork ~ part1(10, 0);
8 * quarternote => now;
spork ~ part2(2, 0);
8 * quarternote => now;
spork ~ part2(2, 4);
8 * quarternote => now;

spork ~ part6();
for (1 => int i; i < 5; i++) {
    spork ~ part2(1, i);
    spork ~ part1(1, i);
    quarternote -.01::second => quarternote;
    4*quarternote => now;
}
.6::second => quarternote;
spork ~ part2(2, 0);
//spork ~ part6();
//8 * quarternote => now;
//spork ~ part5();
//spork ~ part4();

while(1)
{
    quarternote => now;
}

fun void part1(int num, int off) {
    TriOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(300::ms, 300::ms, 0.0, 100::ms);
    part1.gain(.3);
    
    for (0 => int t; t < num ; t++) {
        for (0 => int play; play < melody1.size(); play++) {
            Std.mtof(melody1[play] + off)*0.25 => part1.freq;
            a1.keyOn();
            quarternote/2 => now;
            a1.keyOff();
        }
    }
}

fun void part2(int num, int off) {
    SinOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(300::ms, 300::ms, 0.0, 100::ms);
    nr1.gain(.2);
    
    for (0 => int t; t < num ; t++) {
        for (0 => int play; play < melody2.size(); play++) {
            Std.mtof(melody2[play] + off)*2 => part1.freq;
            a1.keyOn();
            quarternote/4 => now;
            a1.keyOff();
        }
    }
}

fun void part3() {
    SinOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(300::ms, 300::ms, 0.5, 80::second);
    nr1.gain(.2);
    
    Std.mtof(64) => part1.freq;
    a1.keyOn();
    80::second => now;
    
}

fun void part4() {
    Noise n => JCRev r => HPF hp => ADSR e => dac;
    SinOsc s => ADSR e2 => dac;
    
    s.freq(90);
    e.set(4::ms,300::ms,0.0,200::ms);
    e2.set(4::ms,300::ms,0.0,50::ms);
    hp.freq(4000);
    hp.Q(1.0);
    
    [.75, .75, .75, .75, 1] @=> float beats[]; 
    
    0 => int i;
    
    while(1)
    {
        for (0 => int i; i < beats.size(); i++) {
            e2.keyOn();
            e2.decayTime((Math.random2(100, 120))::ms);
            hp.freq(Math.random2(9000, 9000));
            quarternote => now;
            
        
            i++;
        }
    }
}

fun void part5() {
    Noise n => JCRev r => HPF hp => ADSR e => dac;
    SinOsc s => ADSR e2 => dac;
    
    s.gain(.5);
    
    s.freq(90);
    e2.set(4::ms,300::ms,0.0,20::ms);
    hp.freq(4000);
    hp.Q(1.0);
    
    [.75, .75, .75, .75, 1] @=> float beats[]; 
    
    0 => int i;
    
    while(1)
    {
        for (0 => int i; i < beats.size(); i++) {
            e2.keyOn();
            e.decayTime((Math.random2(80, 80))::ms);
            hp.freq(Math.random2(400, 400));
            beats[i] * quarternote => now;
        }
    }
}

fun void part6() {
    Noise n =>  LPF hp  => dac;
    //e.set(4::ms,8*quarternote,0, 0::second);
    hp.freq(1000);
    hp.Q(0.7);
    n.gain(.1);
    
    0 => int i;
    
    
    //e.keyOn();
    //while (true) {
        while(hp.freq() < 8000) {
            hp.freq() + 10 => hp.freq;
            500::samp => now;
        }

    //}
}
