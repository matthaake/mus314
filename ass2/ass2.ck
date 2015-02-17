// set initial values
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

// play the song

// play low part 
spork ~ part1(12, 0);
16 * quarternote => now;

// play melody
spork ~ part2(8, 0);
16 * quarternote => now;

// play chord
spork ~ part3(60);
spork ~ part3(62);
spork ~ part3(64);
spork ~ part3(67);
16*quarternote => now;

// white noise
//spork ~ noise(); 

// play modulation
for (1 => int i; i < 6; i++) {
    spork ~ part2(1, i);
    spork ~ part1(1, i);
    quarternote -.01::second => quarternote;
    4*quarternote => now;
}

// play high part slowly
.6::second => quarternote;
spork ~ part2(2,0);
8*quarternote => now;

// play drop
.5::second => quarternote;
spork ~ drop();

7*quarternote*4 => now;
spork ~ part1(2, 0);
8*quarternote => now;

// let time run in top level
while(1)
{
    quarternote => now;
}

// --------------------------------------------------------------------
// low part
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

// melody
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

// single note of chord
fun void part3(int note) {
    SinOsc part1 => ADSR a1 => NRev nr1 => dac;
    nr1.mix(.06);
    a1.set(8*quarternote, 4*quarternote, 0.5, 0::second);
    nr1.gain(.2);
    
    Std.mtof(note) => part1.freq;
    a1.keyOn();
    16*quarternote => now;
}

// white noise
// need to fix the duration of this
fun void noise() {
    Noise n => LPF hp => ADSR e  => dac;
    e.set(2*quarternote, 0::second, 1, 0::second);
    hp.freq(1000);
    hp.Q(0.7);
    n.gain(.1);
    
    e.keyOn();
    while(hp.freq() < 8000) {
        hp.freq() + 10 => hp.freq;
        500::samp => now;
    }
}

// drop section
fun void drop() {
    SinOsc part => ADSR a => Chorus c => dac;
    SawOsc part2 => ADSR a2 => Chorus c2 => dac;
    
    a.set(50::ms, 250::ms, 0.3, 200::ms);
    a2.set(125::ms, 25::ms, 0.3, 100::ms);
    
    c.modFreq(64);
    c.modDepth(.01);
    c.mix(.5);
    
    int melody[8];
    
    for (0 => int i; i < melody.size(); i++) {
        Math.random2(0, mynotes.size()-1) => dice;
        mynotes[dice] => melody[i];
    }
    
    for (0 => int t; t < 4 ; t++) {
        Std.mtof(melody[0])*0.5 => part.freq;
        a.keyOn();
        quarternote => now;
        a.keyOff();
        Std.mtof(melody[1])*0.5 => part2.freq;
        a2.keyOn();
        quarternote*.5 => now;
        a2.keyOff();
        Std.mtof(melody[2])*0.5 => part.freq;
        a.keyOn();
        quarternote => now;
        a.keyOff();
        Std.mtof(melody[3])*0.5 => part.freq;
        a.keyOn();
        quarternote => now;
        a.keyOff();
        Std.mtof(melody[4])*0.5 => part.freq;
        a.keyOn();
        quarternote => now;
        a.keyOff();
        Std.mtof(melody[5])*0.5 => part2.freq;
        a2.keyOn();
        quarternote*.5 => now;
        a2.keyOff();
        Std.mtof(melody[6])*0.5 => part.freq;
        a.keyOn();
        quarternote => now;
        a.keyOff();
        Std.mtof(melody[7])*0.5 => part.freq;
        a.keyOn();
        quarternote => now;
        a.keyOff();
        
    }
}

