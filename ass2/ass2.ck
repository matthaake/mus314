// set initial values
.5::second => dur quarternote;

[60, 62, 64, 67, 67, 69, 69, 72, 76, 74] @=> int mynotes[];

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

int rev2[16];
for (0 => int i; i < melody2.size(); i++) {
    melody2[i] => rev2[melody2.size() - i - 1];
}

// play the song
// play low part 
spork ~ part1(12, 0);
16 * quarternote => now;

// play melody
spork ~ part2(8, 0, .2);
16 * quarternote => now;

// play chord
spork ~ part3(60);
spork ~ part3(62);
spork ~ part3(64);
spork ~ part3(67);
16*quarternote => now;

// white noise
spork ~ noise(); 

// play modulation
for (1 => int i; i < 6; i++) {
    spork ~ part2(1, i, .2);
    spork ~ part1(1, i);
    quarternote -.01::second => quarternote;
    4*quarternote => now;
}

// play high part slowly
.6::second => quarternote;
spork ~ part3(2, 0, .3);
12*quarternote => now;


// play drop
.5::second => quarternote;
spork ~ drop(7);
7*quarternote*3 => now;
spork ~ part3(1, 0, .03);
8*quarternote => now;
7*quarternote => now;
spork ~ part3(1, 0, .05);
8*quarternote => now;
// play chord
spork ~ part3(60);
spork ~ part3(62);
//spork ~ part2(2, 0, .2);
//8*quarternote => now;

// let time run in top level
while(1)
{
    quarternote => now;
}

// --------------------------------------------------------------------
// low part
fun void part1(int num, int off) {
    TriOsc t => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(300::ms, 125::ms, 0.0, 100::ms);
    t.gain(.3);
    
    for (0 => int i; i < num ; i++) {
        for (0 => int play; play < melody1.size(); play++) {
            Std.mtof(melody1[play] + off)*0.25 => t.freq;
            e.keyOn();
            quarternote/2 => now;
            e.keyOff();
        }
    }
    
    quarternote/2 => now;
}


// melody
fun void part2(int num, int off, float gain) {
    SinOsc s => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(300::ms, 50::ms, 0.0, 100::ms);
    s.gain(gain);
    
    for (0 => int i; i < num ; i++) {
        for (0 => int play; play < melody2.size(); play++) {
            Std.mtof(melody2[play] + off)*2 => s.freq;
            e.keyOn();
            quarternote/4 => now;
            e.keyOff();
        }
    }
    quarternote/4 => now;
}

fun void part3(int num, int off, float gain) {
    SinOsc s => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(300::ms, 50::ms, 0.0, 100::ms);
    s.gain(gain);
    
    for (0 => int i; i < num ; i++) {
        for (0 => int play; play < melody2.size(); play++) {
            Std.mtof(melody2[play] + off)*2 => s.freq;
            e.keyOn();
            quarternote/4 => now;
            if (i != num - 1 && play != melody2.size() - 1) {
                e.keyOff();
            }
        }
    } 
    e.set(300::ms, 400::ms, 0.0, 100::ms);
    4*quarternote => now;
    e.keyOff();
    quarternote / 4 => now;
}

// single note of chord
fun void part3(int note) {
    SinOsc s => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(8*quarternote, 6*quarternote, 0.0, 0::second);
    nr.gain(.2);
    
    Std.mtof(note) => s.freq;
    e.keyOn();
    16*quarternote => now;
}

// white noise
// need to fix the duration of this
fun void noise() {
    Noise n => LPF lpf => ADSR e => dac;
    e.set(2*quarternote, 0::second, 1, 0::second);
    lpf.freq(1000);
    lpf.Q(0.7);
    n.gain(.1);
    
    (.99 + .98 + .97 + .96 + .95) * 4 * quarternote => dur total;
    0::ms => dur count;
    e.keyOn();
    while(count < total) {
        lpf.freq() + 10 => lpf.freq;
        500::samp => now;
        500::samp + count => count;
    }
    e.keyOff();
}

// drop section
fun void drop(int num) {
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
    
    for (0 => int t; t < num ; t++) {
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
    quarternote => now;
}

