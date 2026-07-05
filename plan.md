# Keyboard

This project is a keyboard application that I'm building with Zig. It uses the
PortAudio library to play keyboard sounds right from your keyboard.

## Interface

The user will have 24 notes available spanning 3 octaves.

- Octave 1: Z X C V N M , .
- Octave 2: A S D F J K L ;
- Octave 3: Q W E R U I O P

The user can use the left Shift key to lower a note by a semi-tone and the
right Shift key to raise a note by a semi-tone.

## Keys

Not to be confused with keyboard keys. Users can select from a list of musical
keys and modes that adjust the frequency of their interface keys. The
application will always default to C Major on startup.

## Starting note

The user can set the starting note of their current key to be something other
than the root note. All other notes will adjust accordingly to stay within the
key.

## Wave type

We'll let users pick between a sine wave and a sawtooth wave. In the future,
I may add more wave forms.

## Architecture

I've never done audio programming, so a lot of this may change as I learn
more. The plan is to use PortAudio as an audio channel and to have a structure
representing the synth state like so:
SynthState

- phase (0.0 to 2*M_PI if sine wave)
- targetFreq
- currentFreq
- sampleRate (44100.0 or 48000.0)

### frequencyArray

We will have a fixed array on the stack that holds the frequency values for
88 notes. When a key is pressed, this array is accessed like so:

- frequencyArray[startIndex + keyRootOffset + octaveOffset + intervalArray[2] + startOffset + shiftOffset]

Note that octaveOffset is a placeholder - this is hardcoded for each key on
the keyboard.

Examples:

#### Z key in C major

- startIndex == 27
- keyRootOffset == 0
- octaveOffset == 0
- intervalArray index == 0
- startOffset == 0
- shiftOffset == 0

So, we look up frequencyArray[27], which is 261.63.

#### A key in C major

- startIndex == 27
- keyRootOffset == 0
- octaveOffset = 12
- intervalArray index == 0
  - intervalArray[0] == 0
- startOffset == 0
- shiftOffset == 0

So, we look up frequencyArray[39], which is 523.25.

#### C key in C major

- startIndex == 27
- keyRootOffset == 0
- octaveOffset == 0
- intervalArray index == 2
  - intervalArray[2] == 4
- startOffset == 0
- shiftOffset == 0

So, we look up frequencyArray[31], which is 329.63.

#### D key in C major with starting note set to `A`

- startIndex == 27
- keyRootOffset == 0
- octaveOffset == 12
- intervalArray index == 2
  - intervalArray[2] == 4
- startOffset == -3
- shiftOffset == 0

So, we look up frequencyArray[40], which is 440.00.

#### R key in D major

- startIndex == 27
- keyRootOffset == 2
- octaveOffset == 24
- intervalArray index == 3
  - intervalArray[3] == 5
- startOffset == 0
- shiftOffset == 0

So, we look up frequencyArray[58], which is 1567.98.

#### Z key in C major with the user holding Right Shift

- startIndex == 27
- keyRootOffset == 0
- octaveOffset == 0
- intervalArray index == 0
- startOffset == 0
- shiftOffset == 1

So, we look up frequencyArray[28], which is 277.18.

### startIndex

We keep a constant index of 27 on the stack to represent the root note of the
C key.

Why 27? A reference photo of a keyboard I found had the
1-octave-lower-than-middle-c key as the 28th key. So that's what I'm basing
the frequencyArray on.

### keyRootOffset

For

### intervalArray

We also keep a variable array on the stack that hold the note interval
patterns for the current scale. For a major key, this would look like the
following:

- [0, 2, 4, 5, 7, 9, 11]

If the user switches to a C natural minor key, the values in the interval
array would be updated to:

- [0, 2, 3, 5, 7, 8, 10]

For implementation, we'll use an enum that contains entries with labels such
as `major`, `natural_minor`, `harmonic_minor`, etc. Each one will have an
associated interval array. When the user switches keys, we will overwrite
the values in the intervalArray with the values from the enum lookup.

### startOffset

The user can change the starting note of their keyboard, and this has serveral
implications.

Example:

#### User is in C major and sets their starting note to D

- set startOffset to the value in intervalArray[1]
  - In this case, this value is 2.
- update interval array such that the values
  - [0, 2, 4, 5, 7, 9, 11] change to
  - [0, 2, 3, 5, 7, 9, 10]
    - adjustIntervalArray(intervalArray, offset) -> newIntervalArray:
      var newIntervalArray = [7]
      for (int i=0; i < 7; i++) {
      newIntervalArray[i] = intervalArray - offset
      }
      newIntervalArray[7] = intervalArray[0] + 12 - offset
      return newIntervalArray

### shiftOffset

When the user presses Left Shift, we want to lower all played notes by one
semitone. We do this by setting the shiftOffset variable to -1. When the Left
Shift key is released, we set the shiftOffset variable back to 0.

The same applies for the Right Shift button, except we set the shiftOffset
variable to 1 to raise the note by a semitone.

In the case that the user holds down Left Shift and then holds down Right
Shift, the shiftOffset variable should be 0 until one of the shift keys is
released.
