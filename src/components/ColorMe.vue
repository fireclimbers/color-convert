<template>
  <div class="big-grid">
    <div class="small-grid">
      <div class="small-title">HSL</div>
      <div class="label-side">
        Hue:<br/>
        Saturation:<br/>
        Lightness:
      </div> 
      <div class="input-side">
        <input v-model="hue" class="input-box" v-bind:class="{ wrong: hue === '' ? false : !validateNum(hue, 359) }" v-on:input="updateValue('hsl',$event.target.value)">°<br/>
        <input v-model="sat" class="input-box" v-bind:class="{ wrong: sat === '' ? false : !validateNum(sat, 100) }" v-on:input="updateValue('hsl',$event.target.value)">%<br/>
        <input v-model="lig" class="input-box" v-bind:class="{ wrong: lig === '' ? false : !validateNum(lig, 100) }" v-on:input="updateValue('hsl',$event.target.value)">%
      </div>
    </div>
    <div class="small-grid">
      <div class="small-title">RGB</div>
      <div class="label-side">
        Red:<br/>
        Green:<br/>
        Blue:<br/> 
      </div>
      <div class="input-side">
        <input v-model="red" class="input-box" v-bind:class="{ wrong: red === '' ? false : !validateNum(red, 255) }" v-on:input="updateValue('rgb',$event.target.value)"><br/>
        <input v-model="green" class="input-box" v-bind:class="{ wrong: green === '' ? false : !validateNum(green, 255) }" v-on:input="updateValue('rgb',$event.target.value)"><br/>
        <input v-model="blue" class="input-box" v-bind:class="{ wrong: blue === '' ? false : !validateNum(blue, 255) }" v-on:input="updateValue('rgb',$event.target.value)">
      </div>
    </div>
    <div>
      <div class="small-title">Hex</div>
      #<input v-model="hex" class="input-box" v-bind:class="{ wrong: hex === '' ? false : !validateHex() }" v-on:input="updateValue('hex',$event.target.value)">
    </div>
    <div>
      <div class="output-color" v-bind:style="{ backgroundColor: '#'+hex }"></div>
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
      // fires whenever any input is changed
      if (type == 'hsl') {
        if (!this.validateNum(this.hue, 359)) return;
        if (!this.validateNum(this.sat, 100)) return;
        if (!this.validateNum(this.lig, 100)) return;
        this.hslToRgb();
      } else if (type == 'rgb') {
        if (!this.validateNum(this.red, 255)) return;
        if (!this.validateNum(this.green, 255)) return;
        if (!this.validateNum(this.blue, 255)) return;
        this.rgbToHsl('rgb');
      } else {
        if (!this.validateHex()) return;
        this.rgbToHsl('hex');
      }
    },
    validateNum: function (n, range) {
      if (!isNaN(n)) {
        var nInt = parseInt(n);
        if (nInt >= 0 && nInt <= range) {
          return true;
        }
      }
      return false;
    },
    validateHex: function () {
      var isHex = /(^[0-9A-F]{6}$)|(^[0-9A-F]{3}$)/i.test(this.hex);
      if (isHex) {
        return true;
      }
      return false;
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
.label-side {
  grid-area:main;
  text-align:right;
  margin-right:12px;
}
.input-side {
  grid-area:right;
}
.output-color {
  width:48px;
  height:48px;
}
.input-box {
  border-color: #ccc;
  border-style: solid;
  border-width: 1px;
  border-radius: 3px;
  padding: 3px;
}
.wrong {
  background-color: #f00;
}
</style>
