
require 'selenium-webdriver'

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
search_word = 'ryzen5%203500'
#search_word = 'Intel%20UHD%20Graphics%20730%2811世代%29'
search_url = "https://jp.mercari.com/search?keyword=#{search_word}&status=on_sale"
# メルカリ(検索結果)を開く
driver.get(search_url)

# ちゃんと開けているか確認するためpage_loadのwaitを入れる
driver.manage.timeouts.page_load = @wait_time


# ========== ページ遷移のための処理 ==========

# 以下は「次へ」ボタンを取得するための処理
# 次へ、のリンクしかない(初めのページ)はほかのページとxpathが違うので、下記の通り、2パターンのxpathを
# 拾えるようにする。no such elementsで例外が出ないように、rescueでnilにしてあげる。
begin
  button_single = driver.find_element(:xpath, "//*[@id='search-result']/div/div/div/div[1]/mer-button/button")
rescue
  nil
end

begin
  button_double = driver.find_element(:xpath, "//*[@id='search-result']/div/div/div/div[1]/mer-button[2]/button")
rescue
  nil
end



# ページ遷移のためのループ
while true


  # ========== 商品リンクをクリックする繰り返し ==========
  
  # ポップアップ等が先に出ていると正しく要素を取得できない可能性があるため、ここでサイトを更新
  driver.navigate.refresh
  
  # 欲しい情報がshadow_rootに格納されていたのでshadow_rootの中身を読み込めるよう以下のようにステップを踏んで情報を取得
  begin
    item_list = driver.find_elements(:xpath, "//*[@id='item-grid']/ul/li")
  rescue Selenium::WebDriver::Error::NoSuchElementError
    p 'no such element error!!'
    return
  end
  
  item_links = []
  item_list.each do |item|
    item_num = item_list.find_index(item) + 1
    item_link = driver.find_element(:xpath, "//*[@id='item-grid']/ul/li[#{item_num}]/a").attribute('href')
    item_links << item_link
  end
  
  item_links.each do |link|
    driver.get(link)
    # ちゃんと開けているか確認するためpage_loadのwaitを入れる
    driver.manage.timeouts.page_load = @wait_time
  
    # 商品名を取得
    begin
      shadow_host = driver.find_element(:css, '.mer-spacing-b-2')
      shadow_root = shadow_host.shadow_root
      item_name = shadow_root.find_element(:tag_name, 'h1').text
    rescue Selenium::WebDriver::Error::NoSuchElementError
      p 'no such element error!!'
      return
    end
  
    # 商品名を出力
    p item_name
    
    # 商品URL出力
  #  p link
    
    # 価格を取得
    begin
      shadow_host = driver.find_element(:css, '.mer-spacing-r-8')
      shadow_root = shadow_host.shadow_root
      price = shadow_root.find_element(:css, '.number').text
    rescue Selenium::WebDriver::Error::NoSuchElementError
      p 'no such element error!!'
      return
    end
  
    # 価格を出力
  #  p price
    
    # 概要欄を取得
    begin
      shadow_host = driver.find_element(:xpath, "//*[@id='item-info']/section[2]/mer-show-more")
      shadow_root = shadow_host.shadow_root
      content = shadow_root.find_element(:css, '.content.clamp').text
    rescue Selenium::WebDriver::Error::NoSuchElementError
      p 'no such element error!!'
      return
    end
  
    # 概要欄を出力
  #  p content
  
    sleep 0.8
  end
  
  # ========== 商品情報取得完了後、検索結果一覧ページに戻る ==========
  
  driver.get(search_url)

  sleep 0.5





  # 最終ページ(前へボタンしかない状態)でもbutton_doubleの変数の値が残ってしまい、roopから抜けないので、ここでreset
  button_single = nil
  button_double = nil
  # 各ボタンを再取得
  begin
    button_single = driver.find_element(:xpath, "//*[@id='search-result']/div/div/div/div[1]/mer-button/button")
  rescue
    nil
  end
  
  begin
    button_double = driver.find_element(:xpath, "//*[@id='search-result']/div/div/div/div[1]/mer-button[2]/button")
  rescue
    nil
  end

 
  # button_singleがnil、つまり検索結果が1ページだった場合はもちろんループを抜ける。
  break if button_single == nil
  
  # また最終ページ（button_doubleがnilのまま更新されない)の場合もループを抜ける。
  break if button_double == nil && button_single.text == "前へ"

  # 次のページがある時は「次へ」ボタンを押す処理
  if button_single
    # button_singleをifの条件に書くと少し厄介なことになるので、doubleのほうでひっかける。
    # (2ページ目以降、つまり前へ、次へどちらのボタンもあるページではbutton_singleのxpathが
    # 前へ、次へのbuttonタグを内包する配列のxpathとなっているため、button_singleはnilにならず、前へボタンを取得してしまい、
    # ページが進まなくなる)
    if button_double
      button_double.click
    else
      button_single.click
    end
    sleep 0.8
    # ページ遷移後のURLを新しいsearch_urlとして更新する
    search_url = driver.current_url
  end
end



puts "全部の処理が終わりました。"
# driverをとじる
driver.quit
