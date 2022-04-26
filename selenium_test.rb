require 'selenium-webdriver'

@wait_time = 10
@timeout = 4

# Seleniumの初期化
driver = Selenium::WebDriver.for :chrome
# driverがきちんと起動したか、暗黙的な待機を入れる
driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

# yahooを開く
driver.get('https://www.yahoo.co.jp/')

# ちゃんと開けているか確認するため、page_loadのwaitを入れる
driver.manage.timeouts.page_load = @wait_time

# ブラウザでさせたい動作を記載する
# 今回は検索欄に'CPU'と入力して、検索ボタンを押す処理

begin
  # 検索欄を取得し、値を入力
  driver.find_element(:css, 'input[type="search"]').send_keys 'CPU'
  # 検索ボタンを取得し、クリック
  driver.find_element(:css, 'button[type="submit"]').click
rescue Selenium::WebDriver::Error::NoSuchElementError
  p 'no such element error!!'
  return
end

# ここで待機を入れないと、ページ遷移を待たずしてcurrent_url(https://www.yahoo.co.jp/')を吐き出してdriverが落ちるので、
# page_titleを明示的に指定してwaitをかけている。
# この部分、もっとスマートに書きたい。今後の課題。
page_title = '「CPU」の検索結果 - Yahoo!検索'
wait.until {driver.title == page_title}

# current_pageのURLを取得して出力する処理
cur_url = driver.current_url
puts cur_url

# 戻るボタンを押す
driver.navigate.back
# wait入れなくてもトップページ表示されてURLも取得できたが、wait入れた方が良いのだろうか。

# current_pageのURLを取得して出力する処理
cur_url = driver.current_url
puts cur_url


# 忘れず、driverを閉じること!
driver.quit
