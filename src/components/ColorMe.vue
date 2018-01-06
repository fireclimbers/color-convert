<template>
  <div class="big-grid">
    <div class="small-grid">
      <div class="small-title">HSL</div>
      <div style="grid-area:main;text-align:right;margin-right:12px">
        Hue:<br/>
        Saturation:<br/>
        Lightness:
      </div> 
      <div style="grid-area:right">
        <input v-model="hue" v-on:input="updateValue('hsl',$event.target.value)">°<br/>
        <input v-model="sat" v-on:input="updateValue('hsl',$event.target.value)">%<br/>
        <input v-model="lig" v-on:input="updateValue('hsl',$event.target.value)">%
      </div>
    </div>
    <div class="small-grid">
      <div class="small-title">RGB</div>
      <div style="grid-area:main;text-align:right;margin-right:12px">
        Red:<br/>
        Green:<br/>
        Blue:<br/> 
      </div>
      <div style="grid-area:right">
        <input v-model="red" v-on:input="updateValue('rgb',$event.target.value)"><br/>
        <input v-model="green" v-on:input="updateValue('rgb',$event.target.value)"><br/>
        <input v-model="blue" v-on:input="updateValue('rgb',$event.target.value)">
      </div>
    </div>
    <div>
      <div style="text-align:center">Hex</div>
      #<input v-model="hex" v-on:input="updateValue('hex',$event.target.value)">
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
  methods: {
    updateValue: function (type, val) {
      if (type == 'hsl') {
        this.validateHsl();
      } else if (type == 'rgb') {
        this.validateRgb();
      } else {
        this.validateHex();
      }
    },
    validateHsl: function () {
      if (!isNaN(this.hue) && !isNaN(this.sat) && !isNaN(this.lig)) {
        var hueInt = parseInt(this.hue);
        var satInt = parseInt(this.sat);
        var ligInt = parseInt(this.lig);
        if (hueInt >= 0 && hueInt < 360 && satInt >= 0 && satInt <= 100 && ligInt >= 0 && ligInt <= 100) {
          this.converting = true;
          this.hslToRgb();
        }
      }
    },
    validateRgb: function () {
      if (!isNaN(this.red) && !isNaN(this.green) && !isNaN(this.blue)) {
        var redInt = parseInt(this.red);
        var greenInt = parseInt(this.green);
        var blueInt = parseInt(this.blue);
        if (redInt >= 0 && redInt <= 255 && greenInt >= 0 && greenInt <= 255 && blueInt >= 0 && blueInt <= 255) {
          this.converting = true;
          this.rgbToHsl('rgb');
        }
      }
    },
    validateHex: function () {
      var isHex = /(^[0-9A-F]{6}$)|(^[0-9A-F]{3}$)/i.test(this.hex);
      if (isHex) {
        this.converting = true;
        this.rgbToHsl('hex');
      }
    },
    hslToRgb: function () {
      // convert hsl to rgb
      if (parseInt(this.sat) == 0) {
        var rgb = Math.round(parseInt(this.lig)*255/100);
        this.red = rgb;
        this.green = rgb;
        this.blue = rgb;

        this.rgbToHex(rgb,rgb,rgb);
      }

      var lig = parseInt(this.lig)/100;
      var sat = parseInt(this.sat)/100;

      // TODO not sure what case is for == 0.5
      if (lig < 0.5) {
        var t1 = lig * (1.0+sat);
      } else {
        var t1 = lig + sat - (lig * sat);
      }
      var t2 = 2 * lig - t1;

      var h = this.hue / 360;
      var tR = h + (1/3);
      var tG = h;
      var tB = h - (1/3);

      while (tR < 0) tR += 1;
      while (tR > 1) tR -= 1;
      while (tG < 0) tG += 1;
      while (tG > 1) tG -= 1;
      while (tB < 0) tB += 1;
      while (tB > 1) tB -= 1;

      this.red = Math.round(this.rgbTest(tR, t1, t2)*255);
      this.green = Math.round(this.rgbTest(tG, t1, t2)*255);
      this.blue = Math.round(this.rgbTest(tB, t1, t2)*255);

      this.rgbToHex();
      this.converting = false;
    },
    rgbTest: function (tColor, t1, t2) {
      var test1 = 6 * tColor;
      // TODO not sure what case is for == 1 or 2 for any of them
      if (test1 <= 1) {
        return t2 + ((t1 - t2) * 6 * tColor);
      }

      var test2 = 2 * tColor;
      if (test2 <= 1) {
        return t1;
      }

      var test3 = 3 * tColor;
      if (test3 <= 2) {
        return t2 + ((t1 - t2) * ((2/3) - tColor) * 6);
      }

      return t2;
    },
    rgbToHsl: function (start) {
      // convert rgb to hsl
      if (start == 'rgb') {
        // if starting with rgb values
        var r = parseInt(this.red) / 255;
        var g = parseInt(this.green) / 255;
        var b = parseInt(this.blue) / 255;

        this.rgbToHex();
      } else if (start == 'hex') {
        // if starting with hex values
        this.hexToRgb();

        var r = this.red / 255;
        var g = this.green / 255;
        var b = this.blue / 255;
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
      // TODO not sure what case is for == 50
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
      this.converting = false;
    },
    rgbToHex: function (r, g, b) {
      if (r) {
        var red = r;
        var green = g;
        var blue = b;
      } else {
        var red = this.red;
        var green = this.green;
        var blue = this.blue;
      }

      // change hex value
      var hex1 = parseInt(red).toString(16);
      var hex2 = parseInt(green).toString(16);
      var hex3 = parseInt(blue).toString(16);
      if (hex1.length == 1) hex1 = '0'+hex1;
      if (hex2.length == 1) hex2 = '0'+hex2;
      if (hex3.length == 1) hex3 = '0'+hex3;
      if (/^(.)\1+$/.test(hex1) && /^(.)\1+$/.test(hex2) && /^(.)\1+$/.test(hex3)) {
        this.hex = hex1.substring(0,1)+hex2.substring(0,1)+hex3.substring(0,1);
      } else {
        this.hex = hex1+hex2+hex3;
      }
    },
    hexToRgb: function (h) {
      if (h) {
        var hex = h;
      } else {
        var hex = this.hex;
      }
      if (hex.length == 3) {
        var rStr = hex.substring(0,1)+hex.substring(0,1);
        var gStr = hex.substring(1,2)+hex.substring(1,2);
        var bStr = hex.substring(2)+hex.substring(2);
      } else {
        var rStr = hex.substring(0,2);
        var gStr = hex.substring(2,4);
        var bStr = hex.substring(4);
      }

      // change rgb values
      this.red = parseInt(rStr, 16);
      this.green = parseInt(gStr, 16);
      this.blue = parseInt(bStr, 16);
    },
    percent: function (num) {
      return Math.round(num*100);
    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.big-grid {
  display:grid;
  grid-template-columns: auto auto auto auto;
}
.small-grid {
  display:grid;
  grid-template-areas: 'header header' 'main right';
}
.small-title {
  text-align:center;
  grid-area:header;
}

</style>
