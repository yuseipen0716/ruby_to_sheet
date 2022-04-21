require 'selenium-webdriver'

@wait_time = 10
@timeout = 4

# Seleniumの初期化
driver = Selenium::WebDriver.for :chrome
# driverがきちんと起動したか、暗黙的な待機を入れる
driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

# メルカリを開く
driver.get('https://jp.mercari.com/search?keyword=CPU')

# ちゃんと開けているか確認するためpage_loadのwaitを入れる
driver.manage.timeouts.page_load = @wait_time

# current_pageのURLを取得し、出力
cur_url = driver.current_url
puts cur_url

# driverをとじる
driver.quit
