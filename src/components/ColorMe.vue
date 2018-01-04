<template>
  <div style="display:grid;grid-template-columns: auto auto auto auto;">
    <div style="display:grid;grid-template-areas: 'header header' 'main right';">
      <div style="text-align:center;grid-area:header">HSL</div>
      <div style="grid-area:main;text-align:right;margin-right:12px">
        Hue:<br/>
        Saturation:<br/>
        Lightness:
      </div> 
      <div style="grid-area:right">
        <input v-model="hue">°<br/>
        <input v-model="sat">%<br/>
        <input v-model="lig">%
      </div>
    </div>
    <div style="display:grid;grid-template-areas: 'header header' 'main right';">
      <div style="text-align:center;grid-area:header">RGB</div>
      <div style="grid-area:main;text-align:right;margin-right:12px">
        Red:<br/>
        Green:<br/>
        Blue:<br/> 
      </div>
      <div style="grid-area:right">
        <input v-model="red"><br/>
        <input v-model="green"><br/>
        <input v-model="blue">
      </div>
    </div>
    <div>
      <div style="text-align:center">Hex</div>
      #<input v-model="hex">
    </div>
    <div>
      <div v-bind:style="{ backgroundColor: '#'+hex, width: '48px', height: '48px'}"></div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ColorMe',
  data () {
    return {
      hue: '',
      sat: '',
      lig: '',
      red: '',
      green: '',
      blue: '',
      hex: ''
    }
  },
  watch: {
    hue: function (n) {
      this.validateHsl();
    },
    sat: function (n) {
      this.validateHsl();
    },
    lig: function (n) {
      this.validateHsl();
    },
    red: function (n) {
      this.validateRgb();
    },
    green: function (n) {
      this.validateRgb();
    },
    blue: function (n) {
      this.validateRgb();
    },
    hex: function (newHex) {
      this.validateHex();
    },
  },
  methods: {
    validateHsl: function () {
      if (!isNaN(this.hue) && !isNaN(this.sat) && !isNaN(this.lig)) {
        var hueInt = parseInt(this.hue);
        var satInt = parseInt(this.sat);
        var ligInt = parseInt(this.lig);
        if (hueInt >= 0 && hueInt < 360 && satInt >= 0 && satInt <= 100 && ligInt >= 0 && ligInt <= 100) {
          this.hslToRgb();
        }
      }
    },
    validateRgb: function () {
    console.log('rgb');
      if (!isNaN(this.red) && !isNaN(this.green) && !isNaN(this.blue)) {
        var redInt = parseInt(this.red);
        var greenInt = parseInt(this.green);
        var blueInt = parseInt(this.blue);
        if (redInt >= 0 && redInt <= 255 && greenInt >= 0 && greenInt <= 255 && blueInt >= 0 && blueInt <= 255) {
          this.rgbToHsl('rgb');
        }
      }
    },
    validateHex: function () {
    console.log('hex');
      var isHex = /(^[0-9A-F]{6}$)|(^[0-9A-F]{3}$)/i.test(this.hex);
      if (isHex) {
        this.rgbToHsl('hex');
      }
    },
    hslToRgb: function () {
      // convert hsl to rgb

    },
    rgbToHsl: function (start) {
      // convert rgb to hsl
      if (start == 'rgb') {
        // if starting with rgb values
        var r = parseInt(this.red) / 255;
        var g = parseInt(this.green) / 255;
        var b = parseInt(this.blue) / 255;

        // change hex value
        var hex1 = parseInt(this.red).toString(16);
        var hex2 = parseInt(this.green).toString(16);
        var hex3 = parseInt(this.blue).toString(16);
        if (/^(.)\1+$/.test(hex1) && /^(.)\1+$/.test(hex2) && /^(.)\1+$/.test(hex3)) {
          this.hex = hex1.substring(0,1)+hex2.substring(0,1)+hex3.substring(0,1);
        } else {
          // TODO add 0 at beginning if needed
          this.hex = hex1+hex2+hex3;
        }
      } else if (start == 'hex') {
        // if starting with hex values
        if (this.hex.length == 3) {
          var rStr = this.hex.substring(0,1)+this.hex.substring(0,1);
          var gStr = this.hex.substring(1,2)+this.hex.substring(1,2);
          var bStr = this.hex.substring(2)+this.hex.substring(2);
        } else {
          var rStr = this.hex.substring(0,2);
          var gStr = this.hex.substring(2,4);
          var bStr = this.hex.substring(4);
        }
        var r = parseInt(rStr, 16) / 255;
        var g = parseInt(gStr, 16) / 255;
        var b = parseInt(bStr, 16) / 255;

        // change rgb values
        this.red = parseInt(rStr, 16);
        this.green = parseInt(gStr, 16);
        this.blue = parseInt(bStr, 16);
      }

      // calc lig
      var max = Math.max(r,g,b);
      var min = Math.min(r,g,b);
      this.lig = this.percent((max+min)/2);

      // calc no sat
      if (max == min) {
        this.sat = 0;
        this.hue = 0;
        return;
      }

      // calc sat
      if (this.lig < 50) {
        this.sat = this.percent((max-min)/(max+min));
      } else {
        this.sat = this.percent((max-min)/(2.0-max-min));
      }

      // calc hue
      if (max == r) {
        var h = (g-b)/(max-min);
      } else if (max == g) {
        var h = 2.0 + ((b-r)/(max-min));
      } else {
        var h = 4.0 + ((r-g)/(max-min));
      }

      h *= 60;
      while (h < 0) {
        h += 360;
      }
      while (h >= 360) {
        h -= 360;
      }

      this.hue = Math.round(h);

    },
    percent: function (num) {
      return Math.round(num*100);
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
h1, h2 {
  font-weight: normal;
}
ul {
  list-style-type: none;
  padding: 0;
}
li {
  display: inline-block;
  margin: 0 10px;
}
a {
  color: #42b983;
}
</style>
