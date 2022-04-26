require 'selenium-webdriver'
require 'active_record'
require './search_list_cpu' # CPUの検索リストを読み込み

# ================== DB操作準備 ===================

# DBへの接続設定
ADAPTER = 'sqlite3'
DATABASE = 'search_result.rb'

# 接続
ActiveRecord::Base.establish_connection(adapter: ADAPTER, database: DATABASE)

# cpu_itemテーブル読み込み
class CpuItem < ActiveRecord::Base
end


# ================== DB操作準備 ===================


# ================== Selenium準備 =====================

@wait_time = 10
@timeout = 4

# Seleniumの初期化
driver = Selenium::WebDriver.for :chrome
# windowを最大化(windowの初期サイズだと押せないボタンがあるため)
driver.manage.window.maximize
# driverがきちんと起動したか、暗黙的な待機を入れる
driver.manage.timeouts.implicit_wait = @timeout
wait = Selenium::WebDriver::Wait.new(timeout: @wait_time)

# ================== Selenium準備 =====================


# ================== 商品検索処理 ======================

CPU_LIST.each do | model |
  # ===== 各型番ごとに行う処理 ====
  # DBに登録するためのmodel_idとmodel_nameを取得
  model_id = CPU_LIST.find_index(model) + 1
  puts model_id
end

# ================== 商品検索処理 ======================
