<template>
    <div v-if="signedIn==='signedIn'">
        <input v-model="userName" placeholder="Enter Your Name">
        <button @click="signIn">Enter</button>
    </div>

    <div v-else-if="signedIn==='experiment'" style="text-align: center; width: 100%; height: 600px" @mousemove="mousemove" @click="printPosition">

        <div  v-text="targetValues[targetIndex]" style="font-size: 40px; font-weight: bold"></div>

        <div class="range-value" id="rangeV" v-text="rangeValue" style="font-size: 30px"></div>


        <input v-if="finerSlider" style="width:90%" id="finerRange" type="range" min="000" max="4000" v-model="rangeValue" step="1"
               @input="toggleSteps"  @mousedown="mouseDownSlider" @mouseup="mouseUpSlider">

        <input v-else style="width:90%" id="range" type="range" min="000" max="4000" v-model="rangeValue" step="1">

        <h2 v-text="scrubText" style="height: 60px"></h2>

        <button @click="onEnter" style="height: 70px; width: 130px">Enter</button>
        <h3 v-text="questionNumber"></h3>

        <div style="height: 5px"></div>
        <button class="start-button" @click="onStart" v-if="!started" >Start!</button>

        <div style="height:22node back0px"></div>

        <h2>{{this.inputMethod}}</h2>
        <h2 v-if="finerSlider === true">FinerSlider</h2>
        <h2 v-else>Slider</h2>

    </div>

    <div v-else >
        <h1>All DONE! THANK YOU</h1>
        <a style="font-size: 30px" href="https://docs.google.com/forms/d/e/1FAIpQLScmlldOk6ABD3-6J-ZS_E0NYAL5B8149bQoP7i3HzCikrOZRg/viewform">Continue to Survey</a>
    </div>

</template>

<script>
    import axios from "axios";


export default {
    name: 'App',
    data() {
        return {
            balance: '4',
            inputMethod: 'trackpad',
            finerSlider: false,

            signedIn: "signedIn",
            userName: "",
            started: false,

            cursor_y : -1,
            rangeValue: 2000,
            moveAmount: 0,
            valueOnChange: 0,
            adjustValue: 0,
            beginX: 0,

            scrubSpeed: 1,
            mouseDown: false,
            targetIndex: 0,
            targetValues: [2870,1421, 1835, 964, 2476, 1033, 2812, 411, 3821, 3204],
            counter: 0,
            times: [],
            startTime: null,
            endTime: null,

            finalData: {results:[]},

            onClickX: -1,
            onSensitivityChangeX: -1

        }
    },
    computed: {
        scrubText: function () {
            let ret = "";
            if (this.mouseDown === false) {
                return ""
            }
            if (this.scrubSpeed === 1) {
                ret = "Normal Speed"
            } else if (this.scrubSpeed === 2) {
                ret = "Half Speed"
            } else if (this.scrubSpeed === 4) {
                ret = "Quarter Speed"
            } else if (this.scrubSpeed === 10) {
                ret = "Finer Speed"
            }
            return ret
        },

        questionNumber: function() {
            return (this.targetIndex+1).toString() + "/" + this.targetValues.length.toString()
        }
    },
    components: {
    },
    mounted() {
        this.shuffleArray(this.targetValues);
        this.setUpBalance();
    },
    methods: {
        mouseDownSlider: function() {
            this.mouseDown = true;
        },

        mouseUpSlider: function() {
            this.mouseDown = false;
            this.valueOnChange = this.rangeValue;
            this.scrubSpeed = 1;
        },

        toggleSteps: function() {
            let amountMoved = parseInt((this.rangeValue - this.valueOnChange));
            let amountScrubbed = parseInt(amountMoved/this.scrubSpeed);
            let value = parseInt(this.valueOnChange);
            this.rangeValue = value + amountScrubbed;
        },

        toggleSteps2: function() {
            let amountMoved = parseInt((this.rangeValue - this.valueOnChange));
            console.log("amountMoved " + amountMoved);
            this.accumMove += amountMoved;
            console.log("accumMove" + this.accumMove);
            let value = parseInt(this.valueOnChange);
            if (this.accumMove === this.scrubSpeed || this.accumMove === parseInt(-1 * this.scrubSpeed)) {
                // here amountScrubbed is always going to equal 1 or -1
                let amountScrubbed = parseInt(amountMoved / this.scrubSpeed);
                this.rangeValue = value + amountScrubbed;
                this.valueOnChange = this.rangeValue;
                this.accumMove = 0
            } else {
                this.rangeValue = this.valueOnChange
            }
        },


        mousemove: function(event) {
            //TODO || slider moves when going up levels. Maybe try fix this but if not can just say thats the behaviour we want.
            //TODO || the problem is that valueOnChange is not updating when going up levels so amountMoved goes off the old value and calculates a different value.

            //TODO toggleSteps is called before mousemove so we can accomodate for the change of sensitivity, it keeps jumping
            if (this.mouseDown === true) {
                if (event.pageY < 225) {
                    if (this.cursor_y >= 225) {
                        this.valueOnChange = this.rangeValue;
                        this.moveAmount = 0;

                    }
                    this.scrubSpeed = 1;
                } else if (event.pageY < 350 && event.pageY >= 225) {
                    if (this.cursor_y < 225) {
                        this.valueOnChange = this.rangeValue;
                        this.moveAmount = 0;

                    } else if(this.cursor_y >= 350 ) {
                        this.valueOnChange = this.rangeValue;
                    }
                    this.scrubSpeed = 2;
                } else if (event.pageY < 500 && event.pageY >= 350) {
                    if (this.cursor_y < 350) {
                        this.valueOnChange = this.rangeValue;
                        this.moveAmount = 0;

                    } else if (this.cursor_y >= 500) {
                        this.valueOnChange = this.rangeValue;
                    }
                    this.scrubSpeed = 4;
                } else {
                    if (this.cursor_y < 500) {
                        this.valueOnChange = this.rangeValue;
                        this.moveAmount = 0;

                    }
                    this.scrubSpeed = 10;
                }
                this.cursor_y = event.pageY;
            }

        },

        onEnter: function () {

            if (parseInt(this.rangeValue) === this.targetValues[this.targetIndex] && this.started) {
                console.log("rangevalue equals")
                var slider = 'rangeSlider';
                if (this.finerSlider === true) {
                    slider = 'FinerSlider'
                }
                var totalTime = Date.now() - this.startTime;
                let result = {
                    name: this.userName,
                    value: this.targetValues[this.targetIndex],
                    time: totalTime,
                    input: this.inputMethod,
                    slider: slider
                };

                axios.post('http://localhost:3000/finish', result, {
                    headers: {
                        // Overwrite Axios's automatically set Content-Type
                        'Content-Type': 'application/json'
                    }
                }).then((response) => {
                    console.log(response)
                });

                this.startTime = Date.now();
                this.targetIndex += 1;
                this.rangeValue = 2000;
                this.counter += 1;

                if (this.balance === '1') {
                    this.balance1()
                } else if (this.balance === '2') {
                    this.balance2()
                } else if (this.balance === '3') {
                    this.balance3()
                } else if (this.balance === '4') {
                    this.balance4()
                }

                if (this.counter % 10 === 0 && this.counter !== 0) {
                    this.targetIndex = 0;
                    this.started = false;
                }
                if (this.counter === 40) {
                    this.inputMethod = "ALL DONE";
                    this.signedIn = "done"
                }
            }
        },

        onStart: function () {
            this.startTime = Date.now();
            this.started = true;
            this.rangeValue = 2000;
        },

        signIn: function () {
            if (this.userName !== "") {
                this.signedIn = "experiment"
            }
         },

        shuffleArray: function (array) {
            for (let i = array.length - 1; i > 0; i--) {
                const j = Math.floor(Math.random() * (i + 1));
                [array[i], array[j]] = [array[j], array[i]];
            }
        },

        printPosition: function (event) {
            console.log("X " + event.pageX);
            console.log("Y " + event.pageY);
        },

        setUpBalance: function() {
            if (this.balance === '1') {
                this.finerSlider = false;
                this.inputMethod = 'mouse';
            } else if (this.balance === '2') {
                this.finerSlider = false;
                this.inputMethod = 'trackpad';
            } else if (this.balance === '3') {
                this.finerSlider = true;
                this.inputMethod = 'mouse';
            } else if (this.balance === '4') {
                this.finerSlider = true;
                this.inputMethod = 'trackpad';
            }
        },

        balance1: function() {
            if (this.counter === 10) {
                this.finerSlider = false;
                this.inputMethod = 'trackpad';
            } else if (this.counter === 20) {
                this.finerSlider = true;
                this.inputMethod = 'trackpad';
            } else if (this.counter === 30) {
                this.finerSlider = true;
                this.inputMethod = 'mouse';
            }
        },

        balance2: function() {
            if (this.counter === 10) {
                this.finerSlider = true;
                this.inputMethod = 'mouse';
            } else if (this.counter === 20) {
                this.finerSlider = false;
                this.inputMethod = 'mouse';
            } else if (this.counter === 30) {
                this.finerSlider = true;
                this.inputMethod = 'trackpad';
            }
        },
        balance3: function() {
             if (this.counter === 10) {
                this.finerSlider = true;
                this.inputMethod = 'trackpad';
            } else if (this.counter === 20) {
                this.finerSlider = false;
                this.inputMethod = 'trackpad';
            } else if (this.counter === 30) {
                this.finerSlider = false;
                this.inputMethod = 'mouse';
            }
        },

        balance4: function() {
            if (this.counter === 10) {
                this.finerSlider = false;
                this.inputMethod = 'mouse';
            } else if (this.counter === 20) {
                this.finerSlider = true;
                this.inputMethod = 'mouse';
            } else if (this.counter === 30) {
                this.finerSlider = false;
                this.inputMethod = 'trackpad';
            }
        }

    }
}
</script>

<style>
#app {
  font-family: Avenir, Helvetica, Arial, sans-serif;
  -webkit-font-smoothing: antialiased;
  -moz-osx-font-smoothing: grayscale;
  text-align: center;
  color: #2c3e50;
  margin-top: 60px;
}

input[type=range] {
    pointer-events: none;
}

input[type=range]::-webkit-slider-thumb {
    pointer-events:auto;
}

    .start-button {
        height:50px;
        width: 70px;
        font-weight: bold;
        color: #118617;
        background-color: #f8fff7;
        border-color: #0b750a !important;
        box-shadow: none;
        box-sizing: unset;
    }
</style>
