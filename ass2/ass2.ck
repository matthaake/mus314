// Hannah Ho and Matt Haake
// 2/17/2015
// Programming Assignment #2

// Our song generates 3 different random melodies given a set of
// possible notes, and mixes them with different effects into
// a full composition.

// The command line argument defines the base pitch that the rest of
// the song is played around. This number corresponds to a midi note,
// and thus essentially describes the key and the octave that the
// song will be played in. A good range is anywhere from 50-70, but we
// prefer right at 60.

// --------------------------------------------------------------------
// Global Variables

// The duration of a quarter note
.5::second => dur quarternote;

// Get the command line argument
Std.atoi(me.arg(0)) => int base;

// Build a set of pitches to be used for random melodies, offset from 
// the base pitch.
[0, 2, 4, 7, 7, 9, 9, 12, 16, 14] @=> int mynotes[];
for (0 => int i; i < mynotes.size(); i++) {
    mynotes[i] + base => mynotes[i];
}

// Construct the first random melody
int dice;
int melody1[8];
for (0 => int i; i < melody1.size(); i++) {
    Math.random2(0, mynotes.size()-1) => dice;
    mynotes[dice] => melody1[i];
}

// Construct the second random melody
int melody2[16];
for (0 => int i; i < melody2.size(); i++) {
    Math.random2(0, mynotes.size()-1) => dice;
    mynotes[dice] => melody2[i];
}

// --------------------------------------------------------------------
// Song section functions

// Play the first melody num times, with the pitches offset by off.
// Runs for num * melody1.size() * quarternote / 2 seconds.
fun void part1(int num, int off) {
    // Use a triangle oscillator with an envelope and reverb
    TriOsc t => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(300::ms, 125::ms, 0.0, 100::ms);
    t.gain(.3);
    
    // play melody1 num times
    for (0 => int i; i < num ; i++) {
        for (0 => int play; play < melody1.size(); play++) {
            // melody1 is played two octaves down from the base
            Std.mtof(melody1[play] + off) * 0.25 => t.freq;
            
            // play with 8th notes
            e.keyOn();
            quarternote/2 => now;
            e.keyOff();
        }
    }
    
    // eliminate final click
    quarternote/2 => now;
}


// Play the second melody num times, with the pitches offset by off
// using the specified gain.
// Runs for num * melody2.size() * quarternote / 4 seconds.
fun void part2(int num, int off, float gain) {
    // Use a sine oscillator with an envelope and reverb
    SinOsc s => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(300::ms, 50::ms, 0.0, 100::ms);
    s.gain(gain);
    
    // play melody2 num times
    for (0 => int i; i < num ; i++) {
        for (0 => int play; play < melody2.size(); play++) {
            // melody2 is played an octave up from the base
            Std.mtof(melody2[play] + off)*2 => s.freq;
            
            // play with 16th notes
            e.keyOn();
            quarternote/4 => now;
            e.keyOff();
        }
    }
    
    // eliminate final click
    quarternote/4 => now;
}

// Same as part2(), but holds the final note for an extra measure.
// Runs for num * melody2.size() * quarternote/4 + 4*quarternote seconds.
fun void part2sus(int num, int off, float gain) {
    // Use a sine oscillator with an envelope and reverb
    SinOsc s => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(300::ms, 50::ms, 0.0, 100::ms);
    s.gain(gain);
    
    // play melody2 num times
    for (0 => int i; i < num ; i++) {
        for (0 => int play; play < melody2.size(); play++) {
            // melody2 is played an octave up from the base
            Std.mtof(melody2[play] + off)*2 => s.freq;
            
            // play with 16th notes
            e.keyOn();
            quarternote/4 => now;
            
            // don't end the last note
            if (i != num - 1 && play != melody2.size() - 1) {
                e.keyOff();
            }
        }
    } 
    
    // sustain the last note for an extra measure
    e.set(300::ms, 400::ms, 0.0, 100::ms);
    4*quarternote => now;
    e.keyOff();
    
    // eliminate final click
    quarternote / 4 => now;
}

// Play all of the notes in the array simultaneously, fading in and out.
// Runs for 16 * quarternote seconds
fun void chord(int notes[]) {
    // Spork a process to play each note simultaneously
    for (0 => int i; i < notes.size(); i++) {
        spork ~ single(notes[i]);
    }
}

// Play a single note of a chord.
// Runs for 16 * quarternote seconds.
fun void single(int note) {
    // Use a sine oscillator with an envelope and reverb
    SinOsc s => ADSR e => NRev nr => dac;
    nr.mix(.06);
    e.set(8*quarternote, 6*quarternote, 0.0, 0::second);
    nr.gain(.2);
    
    // Play the note
    Std.mtof(note) => s.freq;
    e.keyOn();
    16*quarternote => now;
    e.keyOff();
    
    // eliminate final click
    quarternote / 4 => now;
    
}

// Plays a sweeping white noise sound for duration.
fun void noise(dur duration) {
    // Use a sine oscillator with an envelope and lowpass filter
    Noise n => LPF lpf => ADSR e => dac;
    e.set(2*quarternote, 0::second, 1, 0::second);
    lpf.freq(1000);
    lpf.Q(0.7);
    n.gain(.1);
    
    // Increase the filter's cutoff over time
    0::ms => dur count;
    e.keyOn();
    while(count < duration) {
        lpf.freq() + 10 => lpf.freq;
        500::samp => now;
        500::samp + count => count;
    }
    e.keyOff();
    
    // eliminate final click
    quarternote / 4 => now;
}

// Play the drop section of the song num times.
// Runs for 7 * quarternote seconds.
fun void drop(int num) {
    // There are two parts to the drop. A sine oscillator
    // and a sawtooth oscillator with envelopes and chorus effects.
    SinOsc part => ADSR a => Chorus c => dac;
    SawOsc part2 => ADSR a2 => Chorus c2 => dac;
    a.set(50::ms, 250::ms, 0.3, 200::ms);
    a2.set(125::ms, 25::ms, 0.3, 100::ms);
    c.modFreq(64);
    c.modDepth(.01);
    c.mix(.5);
    
    // Generate random melody.
    int melody[8];
    for (0 => int i; i < melody.size(); i++) {
        Math.random2(0, mynotes.size()-1) => dice;
        mynotes[dice] => melody[i];
    }
    
    // Play the melody num times split properly across both parts.
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
    
    // eliminate final click
    quarternote => now;
}

// --------------------------------------------------------------------
// Play the song! (the main patch)

// Play the low part 
spork ~ part1(12, 0);
16 * quarternote => now;

// Play the high melody over the low part
spork ~ part2(8, 0, .2);
16 * quarternote => now;

// Add in a sustained chord
chord([base, base+2, base+4, base+7]);
16*quarternote => now;

// Modulate the melodies upwards, building up speed, with
// a sweeping white noise in the background
spork ~ noise((.99 + .98 + .97 + .96 + .95) * 4 * quarternote); 
for (1 => int i; i < 6; i++) {
    spork ~ part2(1, i, .2);
    spork ~ part1(1, i);
    quarternote -.01::second => quarternote;
    4*quarternote => now;
}

// Play the high melody slowly, sustaining the final note
.6::second => quarternote;
spork ~ part2sus(2, 0, .3);
12*quarternote => now;

// Play the drop section 7 times
.5::second => quarternote;
spork ~ drop(7);

// Wait for 3 repetitions of the drop
7 * quarternote * 3 => now;

// Play the high melody quietly above the drop 
spork ~ part2sus(1, 0, .03);
8*quarternote => now;

// Just the drop
6*quarternote => now;

// High melody above drop again.
spork ~ part2sus(1, 0, .05);
8*quarternote => now;

// Finish with a dissonant chord
chord([base, base+2]);
16*quarternote => now;

