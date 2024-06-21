let clipWidth = 136;
let clipHeight = 80;
let marginVertical = 20;
let marginHorizontal = 4;
let clip_i = 0;

let ks_image
let hex_colors = []

function preload() {
  ks_image = loadImage('assets/ks_image.png')
  hex_colors = loadStrings('assets/channel colors.txt') 
}

function setup() {
  print(hex_colors[0])
  frameRate(9)
}

function draw() {
  if (clip_i < midi_data.length) {
    let clip = midi_data[clip_i];
    let pg = createGraphics(clipWidth, clipHeight);
    pg.clear();
    
    let pitchRange = highest_pitches[clip_i] - lowest_pitches[clip_i];
    
    // Organize, then Draw pedal
    let pedalEvents = []
    for (let event of clip) {
      if (event.command == "pedal") {
        pedalEvents[event.pos] = event
      }
    }
    for (let i = 0; i < clip_lengths[clip_i]; i++) {
      if (pedalEvents[i]) {
        if (pedalEvents[i].value > 64) {
          pedalStart = i
        } else {
          pg.noStroke()
          pg.fill(color(255, 255, 255, 15))
          let x = map(pedalStart, 0, clip_lengths[clip_i], marginHorizontal, clipWidth - marginHorizontal)
          let y = clipHeight/4*3
          let w = map(i - pedalStart, 0, clip_lengths[clip_i], marginHorizontal, clipWidth - marginHorizontal)
          let h = clipHeight/4
          pg.rect(x, y, w, h)
          pg.noFill
          pg.stroke(color(255, 255, 255, 100))
          pg.line(x, y, x, clipHeight)
        }
        
      }
    }

    // Draw keyswitches
    for (let event of clip) {
      let x = map(event.pos, 0, clip_lengths[clip_i], marginHorizontal, clipWidth - marginHorizontal);

      if (event.command == "keyswitch") {
        // pg.image(ks_image, x-5, clipHeight-5)

        // pg.noFill()
        // pg.strokeWeight(1)
        // pg.stroke(color(255, 255, 255, 50))
        // pg.line(x, clipHeight, x, 0)
      }
    }
    
    // Draw notes
    for (let event of clip) {
      let h = (clipHeight - marginVertical * 2) / pitchRange;
      let x = map(event.pos, 0, clip_lengths[clip_i], marginHorizontal, clipWidth - marginHorizontal);
      let y = map(event.pitch, lowest_pitches[clip_i], highest_pitches[clip_i], clipHeight - h - marginVertical, marginVertical);
      
      if (event.command == "note") {
        let c = color(hex_colors[event.chan])
        let intensity = map(event.vel, 1, 127, 100, 255);
        c.setAlpha(intensity)
        pg.fill(c);
        pg.noStroke()
        let w = map(event.length, 0, clip_lengths[clip_i], 0, clipWidth - marginHorizontal * 2);
        let radius = 3;
        pg.rect(x, y, w, h, radius);
      }
    }

    saveCanvas(pg, "clip" + clip_i, 'png');
  }
  clip_i++
}
