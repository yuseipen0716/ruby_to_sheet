require 'selenium-webdriver'

# GoogleDriveAPI使用のための準備
require 'google_drive'
session = GoogleDrive::Session.from_config("config.json")

# spreadsheetの読み込み
sheets = session.spreadsheet_by_key("1GiHF8FD1LIC-RVVwQ2cGlRni0wQ9qFAmk9UZ9NqaKWk").worksheets[0]

# sheetへの書き込み
sheets[1,1] = "hello world!"

# sheetの保存
sheets.save



@wait_time = 10
@timeout = 4

# Seleniumの初期化
driver = Selenium::WebDriver.for :chrome
# windowを最大化(windowの初期サイズだと押せないボタンがあるため)
driver.manage.window.maximize
# driverがきちんと起動したか、暗黙的な待機を入れる
driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

# ここを任意の検索ワードに指定する
search_word = 'CPU'

# メルカリ(検索結果)を開く
driver.get("https://jp.mercari.com/search?keyword=#{search_word}")

# ちゃんと開けているか確認するためpage_loadのwaitを入れる
driver.manage.timeouts.page_load = @wait_time



# ========================== ここから商品情報取得のための処理セット ======================================

# ポップアップ等が先に出ていると正しく要素を取得できない可能性があるため、ここでサイトを更新
driver.navigate.refresh

# 欲しい情報がshadow_rootに格納されていたのでshadow_rootの中身を読み込めるよう以下のようにステップを踏んで情報を取得
begin
  # 値段を取得
  shadow_host = driver.find_element(:xpath, "//*[@id='item-grid']/ul/li[1]/a/mer-item-thumbnail")
  shadow_root = shadow_host.shadow_root
  item_link = shadow_root.find_element(:css, '.item-name')
rescue Selenium::WebDriver::Error::NoSuchElementError
  p 'no such element error!!'
  return
end
# item-name(商品名)を取得
item_name = item_link.text
puts item_name

# 商品詳細ページへジャンプ
item_link.click

# ページ読み込みを待つ
page_title = "#{item_name} - メルカリ"
wait.until {driver.title == page_title}

# 商品のURLを取得し、出力
item_url = driver.current_url
puts item_url

begin
  # 値段を取得
  shadow_host = driver.find_element(:xpath, "//*[@id='item-info']/section[1]/section[1]/div/mer-price")
  shadow_root = shadow_host.shadow_root
  price = shadow_root.find_element(:css, '.number').text
rescue Selenium::WebDriver::Error::NoSuchElementError
  p 'no such element error!!'
  return
end

puts price

begin
  # 概要欄を取得していく
  shadow_host = driver.find_element(:xpath, "//*[@id='item-info']/section[2]/mer-show-more")
  shadow_root = shadow_host.shadow_root
  # 概要欄を取得
  content = shadow_root.find_element(:css, '.content').text
rescue Selenium::WebDriver::Error::NoSuchElementError
  p 'no such element error!!'
  return
end
puts content

# 売り切れかどうか判断する処理
begin
  # 売り切れステッカーを取得
  shadow_host = driver.find_element(:xpath, "//*[@id='item-info']/section[1]/div[2]/mer-button")
  shadow_root = shadow_host.shadow_root
  status_text = shadow_root.find_element(:css, '.button').text
  if status_text == "売り切れました"
    status = '売り切れ'
  else
    status = '販売中'
  end
rescue Selenium::WebDriver::Error::NoSuchElementError
  p 'no such element error!!'
  return
end

puts status

#検索結果一覧へ戻る
driver.navigate.back

# ========================== ここまでが1つの処理のセット ======================================

# driverをとじる
driver.quit
