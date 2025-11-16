package main

import (
	"context"
	"fmt"
	"os"
	"path/filepath"
	"time"

	"github.com/chromedp/chromedp"
)

// App struct
type App struct {
	ctx      context.Context
	headless bool // 是否使用无头模式，默认 true（无头）
}

// NewApp creates a new App application struct
func NewApp() *App {
	return &App{
		headless: true, // 默认无头模式
	}
}

// startup is called when the app starts. The context is saved
// so we can call the runtime methods
func (a *App) startup(ctx context.Context) {
	a.ctx = ctx
}

// SetHeadless 设置是否使用无头模式
func (a *App) SetHeadless(headless bool) {
	a.headless = headless
}

// createBrowserContext 创建浏览器上下文，支持有头/无头模式
func (a *App) createBrowserContext() (context.Context, context.CancelFunc) {
	opts := append(chromedp.DefaultExecAllocatorOptions[:],
		chromedp.Flag("headless", a.headless),
		chromedp.Flag("disable-gpu", false),
		chromedp.Flag("disable-dev-shm-usage", false),
	)

	allocCtx, cancel := chromedp.NewExecAllocator(context.Background(), opts...)
	ctx, cancel2 := chromedp.NewContext(allocCtx)

	// 返回一个组合的 cancel 函数
	return ctx, func() {
		cancel2()
		cancel()
	}
}

// Greet returns a greeting for the given name
func (a *App) Greet(name string) string {
	return fmt.Sprintf("Hello %s, It's show time!", name)
}

// OpenBrowserAndScreenshot 打开浏览器，访问指定URL并截图保存
func (a *App) OpenBrowserAndScreenshot(url string, savePath string) (string, error) {
	// 创建上下文，设置超时
	ctx, cancel1 := a.createBrowserContext()
	defer cancel1()

	// 设置超时时间
	ctx, cancel2 := context.WithTimeout(ctx, 30*time.Second)
	defer cancel2()

	var buf []byte

	// 执行浏览器操作
	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(2*time.Second), // 等待页面加载
		chromedp.CaptureScreenshot(&buf),
	)

	if err != nil {
		return "", fmt.Errorf("浏览器操作失败: %v", err)
	}

	// 如果未指定保存路径，使用默认路径
	if savePath == "" {
		savePath = "screenshot.png"
	}

	// 确保目录存在
	dir := filepath.Dir(savePath)
	if dir != "." && dir != "" {
		if err := os.MkdirAll(dir, 0755); err != nil {
			return "", fmt.Errorf("创建目录失败: %v", err)
		}
	}

	// 保存截图
	if err := os.WriteFile(savePath, buf, 0644); err != nil {
		return "", fmt.Errorf("保存截图失败: %v", err)
	}

	// 获取绝对路径
	absPath, err := filepath.Abs(savePath)
	if err != nil {
		absPath = savePath
	}

	return absPath, nil
}

// ClickElement 点击指定元素
func (a *App) ClickElement(url string, selector string, selectorType string) (string, error) {
	ctx, cancel := a.createBrowserContext()
	defer cancel()

	ctx, cancel2 := context.WithTimeout(ctx, 30*time.Second)
	defer cancel2()

	var byQuery chromedp.QueryOption
	switch selectorType {
	case "id":
		byQuery = chromedp.ByID
	case "query":
		byQuery = chromedp.ByQuery
	default:
		byQuery = chromedp.ByQuery
	}

	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(1*time.Second),
		chromedp.WaitVisible(selector, byQuery),
		chromedp.Click(selector, byQuery),
		chromedp.Sleep(1*time.Second),
	)

	if err != nil {
		return "", fmt.Errorf("点击操作失败: %v", err)
	}

	return "点击成功！", nil
}

// InputText 在指定输入框中输入文本
func (a *App) InputText(url string, selector string, text string, selectorType string) (string, error) {
	ctx, cancel := a.createBrowserContext()
	defer cancel()

	ctx, cancel2 := context.WithTimeout(ctx, 30*time.Second)
	defer cancel2()

	var byQuery chromedp.QueryOption
	switch selectorType {
	case "id":
		byQuery = chromedp.ByID
	case "query":
		byQuery = chromedp.ByQuery
	default:
		byQuery = chromedp.ByQuery
	}

	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(1*time.Second),
		chromedp.WaitVisible(selector, byQuery),
		chromedp.Click(selector, byQuery),
		chromedp.Clear(selector, byQuery),
		chromedp.SendKeys(selector, text, byQuery),
		chromedp.Sleep(1*time.Second),
	)

	if err != nil {
		return "", fmt.Errorf("输入操作失败: %v", err)
	}

	return fmt.Sprintf("已输入文本: %s", text), nil
}

// ExecuteJavaScript 执行 JavaScript 代码并返回结果
func (a *App) ExecuteJavaScript(url string, jsCode string) (string, error) {
	ctx, cancel := a.createBrowserContext()
	defer cancel()

	ctx, cancel2 := context.WithTimeout(ctx, 30*time.Second)
	defer cancel2()

	var result interface{}

	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(1*time.Second),
		chromedp.Evaluate(jsCode, &result),
	)

	if err != nil {
		return "", fmt.Errorf("执行 JavaScript 失败: %v", err)
	}

	return fmt.Sprintf("执行结果: %v", result), nil
}

// GetPageTitle 获取页面标题
func (a *App) GetPageTitle(url string) (string, error) {
	ctx, cancel := a.createBrowserContext()
	defer cancel()

	ctx, cancel2 := context.WithTimeout(ctx, 30*time.Second)
	defer cancel2()

	var title string

	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(1*time.Second),
		chromedp.Title(&title),
	)

	if err != nil {
		return "", fmt.Errorf("获取标题失败: %v", err)
	}

	return title, nil
}

// GetElementText 获取指定元素的文本内容
func (a *App) GetElementText(url string, selector string, selectorType string) (string, error) {
	ctx, cancel := a.createBrowserContext()
	defer cancel()

	ctx, cancel2 := context.WithTimeout(ctx, 30*time.Second)
	defer cancel2()

	var text string

	var byQuery chromedp.QueryOption
	switch selectorType {
	case "id":
		byQuery = chromedp.ByID
	case "query":
		byQuery = chromedp.ByQuery
	default:
		byQuery = chromedp.ByQuery
	}

	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.Sleep(1*time.Second),
		chromedp.WaitVisible(selector, byQuery),
		chromedp.Text(selector, &text, byQuery),
	)

	if err != nil {
		return "", fmt.Errorf("获取文本失败: %v", err)
	}

	return text, nil
}

// WaitForElement 等待指定元素出现
func (a *App) WaitForElement(url string, selector string, selectorType string, timeoutSeconds int) (string, error) {
	ctx, cancel := a.createBrowserContext()
	defer cancel()

	if timeoutSeconds <= 0 {
		timeoutSeconds = 10
	}

	ctx, cancel2 := context.WithTimeout(ctx, time.Duration(timeoutSeconds)*time.Second)
	defer cancel2()

	var byQuery chromedp.QueryOption
	switch selectorType {
	case "id":
		byQuery = chromedp.ByID
	case "query":
		byQuery = chromedp.ByQuery
	default:
		byQuery = chromedp.ByQuery
	}

	err := chromedp.Run(ctx,
		chromedp.Navigate(url),
		chromedp.WaitVisible("body", chromedp.ByQuery),
		chromedp.WaitVisible(selector, byQuery),
	)

	if err != nil {
		return "", fmt.Errorf("等待元素超时或失败: %v", err)
	}

	return fmt.Sprintf("元素已出现: %s", selector), nil
}
