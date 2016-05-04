<!DOCTYPE html>
<html lang="en">
<head>
	<meta charset="UTF-8">
	<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
	<title>transfer</title>
	<script src="/vue.min.js"></script>
	<style>
		* {
			margin: 0;
			padding: 0;
			box-sizing: content-box;
		}
		html {
			font-size: 20px;
		}
		body {
			font-family: "Helvetica Neue",Helvetica,"Hiragino Sans GB",STHeiti,"Microsoft YaHei","Wenquanyi Micro Hei","WenQuanYi Micro Hei Mono","WenQuanYi Zen Hei","WenQuanYi Zen Hei Mono",sans-serif;
			-webkit-tap-highlight-color:transparent;
		}
		html,body {
			height: 100%;
			width: 100%;
		}
		@media screen and (min-width: 360px){
		    html {
		        font-size: 23px !important;
		    }
		}

		@media screen and (min-width: 401px){
		    html {
		        font-size: 25px !important;
		    }
		}
		@media screen and (min-width: 428px){
		    html {
		        font-size: 26.75px !important;
		    }
		}
		@media screen and (min-width: 481px){
		    html {
		        font-size: 30px !important; 
		    }
		}
		@media screen and (min-width: 569px){
		    html {
		        font-size: 35px !important; 
		    }
		}
		@media screen and (min-width: 641px){
		    html {
		        font-size: 40px !important; 
		    }
		}
		img {
			max-width: 100%;
		}
		#app {
			display: -webkit-flex;
			display: flex;
			justify-content: center;
			align-items: center;
			width: 100%;
			height: 100%;
		}
		.upload {
			position: relative;
			overflow: hidden;
			text-align: center;
			/* box-shadow: 0 0 1rem rgba(0,0,0,.4); */
		}
		#app p {
			font-size: 18px;
			text-align: center;
			color: #777;
		}
		.upload input[type=file] {
			opacity: 0;
			position: absolute;
			top: 0;
			left: 0;
			bottom: 0;
			right: 0;
			width: 100%;
			height: 100%;
			cursor: pointer;
		}
		.progress em {
			font-size: 4rem;
			font-style: normal;
			color: #CA3434;
		}
		.ft {
			position: absolute;
			bottom: 10px;
			left: 50%;
			-webkit-transform: translateX(-50%);
			transform: translateX(-50%);
			font-size: 12px;
			color: #999;
			text-align: center;
		}
		.ft a {
			text-decoration: none;
			color: #555;
		}
	</style>
</head>
<body>
	<div id="app">
		<div class="upload" v-if="done">
			<input type="file" v-on:change="upload" v-on:drop.prevent.stop="drop" v-on:dragover.prevent.stop="dragover" multiple>
			<img src="/files@2x-vflvkuH8g.png" alt="">
			<p>点击区域，或者拖动文件到这里来</p>
		</div>
		<div class="progress" v-if="!done">
			<em>{{percent}}</em>
			<p>上传中...</p>
		</div>
	</div>
	<a href="https://github.com/otarim/transfer"><img style="position: absolute; top: 0; right: 0; border: 0;" src="https://camo.githubusercontent.com/38ef81f8aca64bb9a64448d0d70f1308ef5341ab/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f6461726b626c75655f3132313632312e706e67" alt="Fork me on GitHub" data-canonical-src="https://s3.amazonaws.com/github/ribbons/forkme_right_darkblue_121621.png"></a>
</body>
<script>
	var xx = new Vue({
		el: '#app',
		data: {
			percent: '10.20%',
			done: true
		},
		ready() {
		},
		methods: {
			drop(e) {
				this.upload({
					target: {
						files: e.dataTransfer.files
					}
				})
			},
			dragover(e) {
				e.dataTransfer.dropEffect = 'copy'
			},
			upload(e) {
				var files = e.target.files
				if(files.length){
					var xhr = new XMLHttpRequest,
						fd = new FormData
					xhr.open('post','/upload',true)
					xhr.error = function(){
						alert('出错了')
					}
					xhr.upload.onprogress = function(e){
						this.percent = (e.loaded / e.total * 1e2).toFixed(2) + '%'
						if(e.loaded === e.total){
							this.done = true
						}
					}.bind(this)
					Object.keys(files).forEach(function(index){
						fd.append('file',files[index])
					})
					xhr.send(fd)
					this.done = false
				}
			}
		}
	})
</script>
</html>