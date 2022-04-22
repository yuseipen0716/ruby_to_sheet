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

# ポップアップ等が先に出ていると正しく要素を取得できない可能性があるため、ここでサイトを更新
driver.navigate.refresh

# 欲しい情報がshadow_rootに格納されていたのでshadow_rootの中身を読み込めるよう以下のようにステップを踏んで情報を取得
shadow_host = driver.find_element(:xpath, "//*[@id='item-grid']/ul/li[1]/a/mer-item-thumbnail")
shadow_root = shadow_host.shadow_root
item_link = shadow_root.find_element(:css, '.item-name')
# item-nameのinnnerTextは今後使用するので変数に格納しておく(一応これ商品名です。)
item_name = item_link.text
puts item_name

# 次はリンクをclickして、current_urlを拾ってきて値段等の情報をみにいく

# driverをとじる
driver.quit
