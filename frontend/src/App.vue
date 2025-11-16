<script setup>
import { reactive } from 'vue'
import {
  OpenBrowserAndScreenshot,
  ClickElement,
  InputText,
  ExecuteJavaScript,
  GetPageTitle,
  GetElementText,
  WaitForElement,
  SetHeadless
} from '../wailsjs/go/main/App'

const state = reactive({
  headless: true, // 默认无头模式
  screenshot: { url: 'https://www.baidu.com', savePath: 'screenshot.png', result: '', loading: false },
  click: { url: 'https://www.baidu.com', selector: '#su', selectorType: 'id', result: '', loading: false },
  input: { url: 'https://www.baidu.com', selector: '#kw', text: 'chromedp', selectorType: 'id', result: '', loading: false },
  js: { url: 'https://www.baidu.com', code: 'document.title', result: '', loading: false },
  title: { url: 'https://www.baidu.com', result: '', loading: false },
  text: { url: 'https://www.baidu.com', selector: 'body', selectorType: 'query', result: '', loading: false },
  wait: { url: 'https://www.baidu.com', selector: '#kw', selectorType: 'id', timeout: 10, result: '', loading: false }
})

const toggleHeadless = () => {
  SetHeadless(state.headless)
}

// 初始化时设置一次
SetHeadless(state.headless)

const run = (key, fn, format) => {
  state[key].loading = true
  state[key].result = '正在处理...'
  fn().then(r => {
    state[key].result = format ? format(r) : r
    state[key].loading = false
  }).catch(err => {
    state[key].result = `失败: ${err}`
    state[key].loading = false
  })
}

const takeScreenshot = () => run('screenshot', () => OpenBrowserAndScreenshot(state.screenshot.url, state.screenshot.savePath), r => `成功！保存路径: ${r}`)
const clickElement = () => run('click', () => ClickElement(state.click.url, state.click.selector, state.click.selectorType))
const inputText = () => run('input', () => InputText(state.input.url, state.input.selector, state.input.text, state.input.selectorType))
const executeJS = () => run('js', () => ExecuteJavaScript(state.js.url, state.js.code))
const getTitle = () => run('title', () => GetPageTitle(state.title.url), r => `页面标题: ${r}`)
const getElementText = () => run('text', () => GetElementText(state.text.url, state.text.selector, state.text.selectorType), r => `文本内容: ${r.substring(0, 100)}${r.length > 100 ? '...' : ''}`)
const waitForElement = () => run('wait', () => WaitForElement(state.wait.url, state.wait.selector, state.wait.selectorType, state.wait.timeout))

const cards = [
  { key: 'screenshot', title: '📸 页面截图', btnText: '开始截图', action: takeScreenshot, fields: [
    { key: 'url', label: '网址', placeholder: 'https://www.baidu.com' },
    { key: 'savePath', label: '保存路径', placeholder: 'screenshot.png' }
  ]},
  { key: 'click', title: '🖱️ 点击元素', btnText: '点击元素', action: clickElement, fields: [
    { key: 'url', label: '网址' },
    { key: 'selector', label: '选择器', placeholder: '#su' },
    { key: 'selectorType', label: '类型', type: 'select', options: [{value:'id',label:'ID'},{value:'query',label:'CSS选择器'}] }
  ]},
  { key: 'input', title: '⌨️ 输入文本', btnText: '输入文本', action: inputText, fields: [
    { key: 'url', label: '网址' },
    { key: 'selector', label: '选择器', placeholder: '#kw' },
    { key: 'text', label: '输入文本' },
    { key: 'selectorType', label: '类型', type: 'select', options: [{value:'id',label:'ID'},{value:'query',label:'CSS选择器'}] }
  ]},
  { key: 'js', title: '⚡ 执行 JavaScript', btnText: '执行代码', action: executeJS, fields: [
    { key: 'url', label: '网址' },
    { key: 'code', label: 'JS代码', type: 'textarea', rows: 3 }
  ]},
  { key: 'title', title: '📄 获取页面标题', btnText: '获取标题', action: getTitle, fields: [
    { key: 'url', label: '网址' }
  ]},
  { key: 'text', title: '📝 获取元素文本', btnText: '获取文本', action: getElementText, fields: [
    { key: 'url', label: '网址' },
    { key: 'selector', label: '选择器', placeholder: 'body' },
    { key: 'selectorType', label: '类型', type: 'select', options: [{value:'id',label:'ID'},{value:'query',label:'CSS选择器'}] }
  ]},
  { key: 'wait', title: '⏳ 等待元素出现', btnText: '等待元素', action: waitForElement, fields: [
    { key: 'url', label: '网址' },
    { key: 'selector', label: '选择器', placeholder: '#kw' },
    { key: 'selectorType', label: '类型', type: 'select', options: [{value:'id',label:'ID'},{value:'query',label:'CSS选择器'}] },
    { key: 'timeout', label: '超时(秒)', type: 'number', min: 1, max: 60 }
  ]}
]
</script>

<template>
  <div class="max-w-[1400px] mx-auto">
    <header class="text-center mb-8 text-white">
      <h1 class="text-4xl mb-2 font-bold">浏览器自动化测试工具</h1>
      <p class="text-lg mb-4">基于 chromedp 的浏览器自动化功能测试</p>
      <div class="flex items-center justify-center gap-3">
        <label class="flex items-center gap-2 cursor-pointer">
          <input type="checkbox" v-model="state.headless" @change="toggleHeadless" class="w-4 h-4"/>
          <span class="text-sm">无头模式（不显示浏览器窗口）</span>
        </label>
      </div>
    </header>
    <div class="grid grid-cols-[repeat(auto-fill,minmax(350px,1fr))] gap-5">
      <div v-for="card in cards" :key="card.key" class="bg-white rounded-lg shadow overflow-hidden border border-gray-200">
        <div class="bg-gray-700 text-white px-5 py-4">
          <h3 class="text-xl font-semibold">{{ card.title }}</h3>
        </div>
        <div class="p-5">
          <div v-for="field in card.fields" :key="field.key" class="mb-4">
            <label class="block mb-1 text-gray-800 font-medium text-sm">{{ field.label }}:</label>
            <input v-if="field.type !== 'select' && field.type !== 'textarea'" 
              v-model="state[card.key][field.key]" 
              :type="field.type || 'text'"
              :placeholder="field.placeholder"
              :min="field.min" :max="field.max"
              class="w-full p-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500"/>
            <select v-else-if="field.type === 'select'" 
              v-model="state[card.key][field.key]"
              class="w-full p-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500">
              <option v-for="opt in field.options" :key="opt.value" :value="opt.value">{{ opt.label }}</option>
            </select>
            <textarea v-else 
              v-model="state[card.key][field.key]"
              :rows="field.rows || 3"
              class="w-full p-2.5 border border-gray-300 rounded text-sm focus:outline-none focus:border-blue-500 font-mono resize-y"/>
          </div>
          <button @click="card.action" :disabled="state[card.key].loading" 
            class="w-full p-3 bg-blue-500 text-white rounded text-base font-semibold mt-2.5 hover:bg-blue-600 disabled:bg-gray-300 disabled:cursor-not-allowed">
            {{ state[card.key].loading ? '处理中...' : card.btnText }}
          </button>
          <div v-if="state[card.key].result" class="mt-4 p-3 bg-gray-100 rounded border-l-4 border-blue-500 text-sm text-gray-800 break-all leading-6">
            {{ state[card.key].result }}
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

