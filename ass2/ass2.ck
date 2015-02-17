.5::second => dur quarternote;


[60, 62, 64, 69, 67, 69, 72, 76, 84, 67] @=> int mynotes[];

int dice;

spork ~ part1();

8::second => now;

spork ~ part3();

while(1)
{
    quarternote => now;
}

fun void part1() {
    TriOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(300::ms, 300::ms, 0.0, 100::ms);
    
    int melody1[8];
    for (0 => int i; i < melody1.size(); i++) {
        Math.random2(0, mynotes.size()-1) => dice;
        mynotes[dice] => melody1[i];
    }
    
    for (0 => int t; t < 80 ; t++) {
        for (0 => int play; play < melody1.size(); play++) {
            Std.mtof(melody1[play])*0.25 => part1.freq;
            a1.keyOn();
            quarternote/2 => now;
            a1.keyOff();
        }
    }
}

fun void part2() {
    SqrOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(300::ms, 300::ms, 0.0, 100::ms);
    nr1.gain(.2);
    
    int melody1[12];
    for (0 => int i; i < melody1.size(); i++) {
        Math.random2(0, mynotes.size()-1) => dice;
        mynotes[dice] => melody1[i];
    }
    
    for (0 => int t; t < 80 ; t++) {
        for (0 => int play; play < melody1.size(); play++) {
            Std.mtof(melody1[play])*0.5 => part1.freq;
            a1.keyOn();
            quarternote => now;
            a1.keyOff();
        }
    }
}

fun void part3() {
    SqrOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(300::ms, 300::ms, 0.0, 100::ms);
    nr1.gain(.2);
    
    int melody1[16];
    for (0 => int i; i < melody1.size(); i++) {
        Math.random2(0, mynotes.size()-1) => dice;
        mynotes[dice] => melody1[i];
    }
    
    for (0 => int t; t < 80 ; t++) {
        for (0 => int play; play < melody1.size(); play++) {
            Std.mtof(melody1[play])*2 => part1.freq;
            a1.keyOn();
            quarternote/4 => now;
            a1.keyOff();
        }
    }
}