<script setup>
import {reactive} from 'vue'
import {Greet, OpenBrowserAndScreenshot} from '../../wailsjs/go/main/App'

const data = reactive({
  name: "",
  resultText: "Please enter your name below 👇",
  url: "https://www.baidu.com",
  savePath: "screenshot.png",
  screenshotResult: "",
  loading: false,
})

function greet() {
  Greet(data.name).then(result => {
    data.resultText = result
  })
}

function takeScreenshot() {
  data.loading = true
  data.screenshotResult = "正在打开浏览器并截图..."
  
  OpenBrowserAndScreenshot(data.url, data.savePath)
    .then(result => {
      data.screenshotResult = `截图成功！保存路径: ${result}`
      data.loading = false
    })
    .catch(err => {
      data.screenshotResult = `截图失败: ${err}`
      data.loading = false
    })
}

</script>

<template>
  <main>
    <div id="result" class="result">{{ data.resultText }}</div>
    <div id="input" class="input-box">
      <input id="name" v-model="data.name" autocomplete="off" class="input" type="text"/>
      <button class="btn" @click="greet">Greet</button>
    </div>
    
    <div class="browser-section">
      <h3>浏览器自动化</h3>
      <div class="input-group">
        <label>网址:</label>
        <input v-model="data.url" class="input" type="text" placeholder="https://www.baidu.com"/>
      </div>
      <div class="input-group">
        <label>保存路径:</label>
        <input v-model="data.savePath" class="input" type="text" placeholder="screenshot.png"/>
      </div>
      <button class="btn btn-primary" @click="takeScreenshot" :disabled="data.loading">
        {{ data.loading ? '处理中...' : '打开浏览器并截图' }}
      </button>
      <div v-if="data.screenshotResult" class="result-text">{{ data.screenshotResult }}</div>
    </div>
  </main>
</template>

<style scoped>
.result {
  height: 20px;
  line-height: 20px;
  margin: 1.5rem auto;
}

.input-box .btn {
  width: 60px;
  height: 30px;
  line-height: 30px;
  border-radius: 3px;
  border: none;
  margin: 0 0 0 20px;
  padding: 0 8px;
  cursor: pointer;
}

.input-box .btn:hover {
  background-image: linear-gradient(to top, #cfd9df 0%, #e2ebf0 100%);
  color: #333333;
}

.input-box .input {
  border: none;
  border-radius: 3px;
  outline: none;
  height: 30px;
  line-height: 30px;
  padding: 0 10px;
  background-color: rgba(240, 240, 240, 1);
  -webkit-font-smoothing: antialiased;
}

.input-box .input:hover {
  border: none;
  background-color: rgba(255, 255, 255, 1);
}

.input-box .input:focus {
  border: none;
  background-color: rgba(255, 255, 255, 1);
}

.browser-section {
  margin-top: 3rem;
  padding: 1.5rem;
  background-color: rgba(240, 240, 240, 0.3);
  border-radius: 8px;
}

.browser-section h3 {
  margin: 0 0 1rem 0;
  color: #333;
}

.input-group {
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 10px;
}

.input-group label {
  min-width: 80px;
  color: #333;
}

.input-group .input {
  flex: 1;
  max-width: 400px;
}

.btn-primary {
  width: auto;
  min-width: 150px;
  height: 36px;
  background-color: #4CAF50;
  color: white;
  font-weight: bold;
  margin-top: 0.5rem;
}

.btn-primary:hover {
  background-color: #45a049;
}

.btn-primary:disabled {
  background-color: #cccccc;
  cursor: not-allowed;
}

.result-text {
  margin-top: 1rem;
  padding: 0.5rem;
  background-color: rgba(255, 255, 255, 0.8);
  border-radius: 4px;
  color: #333;
  word-break: break-all;
}
</style>
