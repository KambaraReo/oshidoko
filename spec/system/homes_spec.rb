require 'rails_helper'

RSpec.describe "homes", type: :system, js: true do
  describe "トップページ" do
    let(:user) { create(:user) }

    before do
      visit root_path
    end

    describe "ヘッダー" do
      it_behaves_like "header"
    end

    describe "サイト説明エリア" do
      describe "リンク" do
        it "MAP表示エリア, POSTS表示エリアに遷移するリンクが表示されていること" do
          within ".links" do
            expect(page).to have_link "MAP"
            expect(page).to have_link "POSTS"
          end
        end

        it "MPAリンクをクリックした時, MAP表示エリアに遷移すること" do
          within ".links" do
            click_link "MAP"
          end
          expect(page).to have_css "#map-anchor", visible: false
        end

        it "POSTSリンクをクリックした時, POSTS表示エリアに遷移すること" do
          within ".links" do
            click_link "POSTS"
          end
          expect(page).to have_css "#posts-anchor", visible: false
        end

        describe "ログイン前" do
          it "ログインページに遷移するリンクが表示されていること" do
            within ".context" do
              expect(page).to have_link "ログインはこちら"
            end
          end

          it "ログインリンクをクリックした時, ログインページに遷移すること" do
            within ".context" do
              click_link "ログインはこちら"
            end
            expect(page).to have_current_path new_user_session_path
          end
        end

        describe "ログイン後" do
          before do
            login(user)
            visit root_path
          end

          it "ログインページに遷移するリンクが表示されていないこと" do
            within ".context" do
              expect(page).to_not have_link "ログインはこちら"
            end
          end
        end
      end
    end

    describe "MAPエリア" do
      it "マーカーピンをクリックするとinfowindowが表示されること" do
        post = create(:post)

        visit root_path
        within ".posts-map-area" do
          find("div[title='marker-#{post.id}']").click
          expect(page).to have_selector "#marker-#{post.id}"
        end
      end

      it "他のマーカーピンをクリックした時, 表示されていたinfowindowが閉じられること" do
        posts = create_list(:post, 2)
        posts[0].update(latitude: "36.8", longitude: "140.0")
        posts[1].update(latitude: "35.8", longitude: "139.8")

        visit root_path
        visit root_path(anchor: "map-anchor")
        within ".posts-map-area" do
          find("div[title='marker-#{posts[0].id}']").click
          find("div[title='marker-#{posts[1].id}']").click
          expect(page).to_not have_selector "#marker-#{posts[0].id}"
        end
      end

      it "投稿数と等しい数のマーカーピンが表示されていること" do
        posts = create_list(:post, 5)

        visit root_path
        within ".posts-map-area" do
          expect(page.all("div[title^='marker-']").count).to eq(posts.count)
        end
      end

      describe "infowindowの確認" do
        let!(:post) { create(:post, user: user) }

        before do
          visit root_path
        end

        describe "画像の表示" do
          context "画像が投稿されている場合" do
            let!(:post_with_pictures) do
              create(:post,
                latitude: 36.8,
                longitude: 140.0,
                user: user,
                pictures: [
                  {
                    io: File.open("#{Rails.root}/spec/fixtures/512bytes_sample.png"),
                    filename: "512bytes_sample.png",
                    content_type: "image/png",
                  },
                  {
                    io: File.open("#{Rails.root}/spec/fixtures/1megabytes_sample.jpeg"),
                    filename: "1megabytes_sample.jpeg",
                    content_type: "image/jpeg",
                  },
                ])
            end

            before do
              visit root_path
              visit root_path(anchor: "map-anchor")
            end

            it "投稿画像の1枚目のみが表示されていること" do
              within ".posts-map-area" do
                find("div[title='marker-#{post_with_pictures.id}']").click
              end
              within "#marker-#{post_with_pictures.id}" do
                expect(page).to have_selector "img[src*='#{post_with_pictures.pictures[0].filename}']"
                expect(page).to_not have_selector "img[src*='#{post_with_pictures.pictures[1].filename}']"
              end
            end
          end

          context "画像が投稿されていない場合" do
            it "デフォルト画像が表示されていること" do
              within ".posts-map-area" do
                find("div[title='marker-#{post.id}']").click
              end
              within "#marker-#{post.id}" do
                expect(page).to have_selector "img[src*='default_post']"
              end
            end
          end
        end

        it "投稿タイトルが表示されていること" do
          within ".posts-map-area" do
            find("div[title='marker-#{post.id}']").click
          end
          within "#marker-#{post.id}" do
            expect(page).to have_link post.title
          end
        end

        it "投稿タイトルをクリックした時, 投稿詳細ページに遷移すること" do
          within ".posts-map-area" do
            find("div[title='marker-#{post.id}']").click
            click_link post.title
          end
          expect(page).to have_current_path post_path(post)
        end

        it "住所が表示されていること" do
          within ".posts-map-area" do
            find("div[title='marker-#{post.id}']").click
          end
          within "#marker-#{post.id}" do
            expect(page).to have_content post.address
          end
        end

        describe "関連メンバーの表示" do
          context "関連メンバーが設定されている場合" do
            it "関連メンバーが表示されていること" do
              within ".posts-map-area" do
                find("div[title='marker-#{post.id}']").click
              end
              within "#marker-#{post.id}" do
                post.members.each do |member|
                  expect(page).to have_content member.name
                end
              end
            end
          end

          context "関連メンバーが設定されていない場合" do
            before do
              post.members.destroy_all
              visit root_path
            end

            it "関連メンバーが表示されていないこと" do
              within ".posts-map-area" do
                find("div[title='marker-#{post.id}']").click
              end
              within "#marker-#{post.id}" do
                expect(page).to_not have_content "関連メンバー"
                post.members.each do |member|
                  expect(page).to_not have_content member.name
                end
              end
            end
          end
        end
      end
    end

    describe "POSTSエリアの表示" do
      describe "投稿の表示確認" do
        let!(:post) { create(:post, user: user) }

        before do
          visit root_path
        end

        it "投稿者のユーザー名, 投稿のタイトル, 住所, 関連メンバー, 作成日が表示されていること" do
          within ".post" do
            expect(page).to have_link post.user.username
            expect(page).to have_link post.title
            expect(page).to have_content post.address
            expect(page).to have_content post.created_at.strftime("%Y年%m月%d日 %H:%M")
          end
        end

        describe "ユーザーアイコンの表示" do
          context "ユーザーアイコンが設定されている場合" do
            let(:user) { create(:user, :with_icon) }

            it "設定されているアイコンが表示されていること" do
              within ".post" do
                expect(page).to have_selector "img[src*='#{user.icon.filename}']"
              end
            end
          end

          context "ユーザーアイコンが設定されていない場合" do
            it "デフォルトアイコンが表示されていること" do
              within ".post" do
                expect(page).to have_selector "img[src*='default_user']"
              end
            end
          end
        end

        describe "関連メンバーの表示" do
          context "関連メンバーが設定されている場合" do
            it "関連メンバーが表示されていること" do
              within ".post" do
                expect(page).to have_content "関連メンバー"
                post.members.each do |member|
                  expect(page).to have_content member.name
                end
              end
            end
          end

          context "関連メンバーが設定されていない場合" do
            before do
              post.members.destroy_all
              visit root_path
            end

            it "関連メンバーが表示されていないこと" do
              within ".post" do
                expect(page).to_not have_content "関連メンバー"
                post.members.each do |member|
                  expect(page).to_not have_content member.name
                end
              end
            end
          end
        end
      end

      describe "リンク" do
        let!(:post) { create(:post, user: user) }

        before do
          visit root_path
        end

        it "ユーザー名をクリックした時, ユーザー詳細ページに遷移すること" do
          within ".post" do
            click_link post.user.username
          end
          expect(page).to have_current_path user_path(post.user)
        end

        describe "ユーザーアイコンのリンク" do
          context "設定されているアイコンをクリックした時" do
            let(:user) { create(:user, :with_icon) }

            it "ユーザー詳細ページに遷移すること" do
              within ".post" do
                find("img[src*='#{user.icon.filename}']").click
              end
              expect(page).to have_current_path user_path(post.user)
            end
          end

          context "デフォルトアイコンをクリックした時" do
            it "ユーザー詳細ページに遷移すること" do
              within ".post" do
                find("img[src*='default_user']").click
              end
              expect(page).to have_current_path user_path(post.user)
            end
          end
        end

        it "投稿タイトルをクリックした時, 投稿詳細ページに遷移すること" do
          within ".post" do
            click_link post.title
          end
          expect(page).to have_current_path post_path(post)
        end

        describe "詳細リンク" do
          context "アイコンをクリックした時" do
            before do
              visit root_path(anchor: "posts-anchor")
            end

            it "投稿詳細ページに遷移すること" do
              within ".post" do
                find("svg[data-icon='circle-info']").click
              end
              expect(page).to have_current_path post_path(post)
            end
          end

          context "詳細をクリックした時" do
            it "投稿詳細ページに遷移すること" do
              within ".post" do
                click_link "詳細"
              end
              expect(page).to have_current_path post_path(post)
            end
          end
        end
      end

      describe "いいね機能の確認" do
        let!(:post) { create(:post) }

        describe "ログイン前" do
          before do
            visit root_path
            visit root_path(anchor: "posts-anchor")
          end

          it "いいねアイコンをクリックすると, ログインページに遷移し, 適切なメッセージが表示されること" do
            within ".favorite" do
              find("svg[data-icon='heart']").click
            end

            expect(page).to have_current_path new_user_session_path
          end
        end

        describe "ログイン後" do
          before do
            login(user)
            visit root_path
            visit root_path(anchor: "posts-anchor")
          end

          context "いいねされていない時" do
            it "いいねアイコンをクリックすると, いいねが追加されること" do
              within ".favorite" do
                find("svg[data-icon='heart']").click
                expect(page).to have_css ".filled-heart"
              end
            end
          end

          context "既にいいねしている時" do
            it "いいねアイコンをクリックすると, いいねが削除されること" do
              within ".favorite" do
                find("svg[data-icon='heart']").click
                expect(page).to have_css ".filled-heart"
                find("svg[data-icon='heart']").click
                expect(page).to have_css ".heart"
              end
            end
          end
        end
      end

      describe "投稿表示順の確認" do
        let!(:posts) { create_list(:post, 4) }

        before do
          posts[0].update(created_at: 3.day.ago)
          posts[1].update(created_at: 2.day.ago)
          posts[2].update(created_at: 1.day.ago)
          posts[3].update(created_at: Time.now)

          visit root_path
        end

        it "投稿が作成日の降順で表示されていること" do
          within ".posts" do
            post_dates = all(".post-created-at").map(&:text)

            expect(post_dates).to eq post_dates.sort.reverse
          end
        end
      end

      describe "ページネーションの確認" do
        Kaminari.config.default_per_page = 25

        context "投稿数が0件の時" do
          before do
            visit root_path
          end

          it "投稿が存在していない旨の表示がされていること" do
            within ".posts" do
              expect(page).to have_content "0件"
              expect(page).to have_content "投稿が存在しません。"
            end
          end
        end

        context "投稿数が20件の時" do
          let!(:posts) { create_list(:post, 20) }

          before do
            visit root_path
          end

          it "投稿件数が正しく表示されていること" do
            within ".posts" do
              expect(page).to have_content "#{posts.count}件中 1-#{posts.count}件を表示"
            end
          end
        end

        context "投稿数が30件の時" do
          let!(:posts) { create_list(:post, 30) }

          before do
            visit root_path
          end

          it "ページネーションリンクが表示されていること" do
            within ".posts" do
              expect(page).to have_css ".pagination"
            end
          end

          it "1ページ目の投稿件数が正しく表示されていること" do
            within ".posts" do
              expect(page).to have_content "#{posts.count}件中 1-25件を表示"
            end
          end

          it "2ページ目の投稿件数が正しく表示されていること" do
            execute_script('window.scrollTo(0, document.body.scrollHeight)')
            sleep 2
            within ".posts" do
              click_link "2"
              expect(page).to have_content "#{posts.count}件中 26-30件を表示"
            end
          end
        end
      end

      describe "投稿検索機能の確認" do
        let(:users) { create_list(:user, 3) }
        let!(:posts) do
          [
            create(:post,
              user: users[0],
              members_count: 0,
              members: [create(:member, name: "mem._1"), create(:member, name: "mem._2")]),
            create(:post,
              user: users[1],
              members_count: 0,
              members: [create(:member, name: "mem._2"), create(:member, name: "mem._3")]),
            create(:post,
              user: users[2],
              members_count: 0,
              members: [create(:member, name: "mem._4")]),
          ]
        end

        before do
          visit root_path
          visit root_path(anchor: "posts-anchor")
        end

        it "キーワードで投稿を検索できること" do
          within ".search-form" do
            fill_in "keyword", with: posts[1].members[0].name
            find("svg[data-icon='magnifying-glass']").click
          end

          within ".posts" do
            expect(page).to have_content posts[0].title
            expect(page).to have_content posts[1].title
            expect(page).to_not have_content posts[2].title
          end
        end

        it "複数キーワードで投稿を検索(AND検索)できること" do
          within ".search-form" do
            fill_in "keyword", with: "#{posts[1].members[0].name} #{posts[1].user.username}"
            find("svg[data-icon='magnifying-glass']").click
          end

          within ".posts" do
            expect(page).to_not have_content posts[0].title
            expect(page).to have_content posts[1].title
            expect(page).to_not have_content posts[2].title
          end
        end

        it "キーワードに該当する投稿がない場合, 投稿が存在しない旨の表示がされること" do
          within ".search-form" do
            fill_in "keyword", with: "tester_4"
            find("svg[data-icon='magnifying-glass']").click
          end

          within ".posts" do
            expect(page).to_not have_content posts[0].title
            expect(page).to_not have_content posts[1].title
            expect(page).to_not have_content posts[2].title
            expect(page).to have_content "0件"
            expect(page).to have_content "投稿が存在しません。"
          end
        end

        it "キーワードが入力されずに検索された場合, 全ての投稿が表示されること" do
          within ".search-form" do
            find("svg[data-icon='magnifying-glass']").click
          end

          within ".posts" do
            expect(page).to have_content posts[0].title
            expect(page).to have_content posts[1].title
            expect(page).to have_content posts[2].title
          end
        end
      end
    end

    describe "投稿ボタン" do
      describe "ログイン前" do
        it "投稿ボタンをクリックすると, ログインページに遷移し, 適切なメッセージが表示されること" do
          find(".post-button").click

          expect(page).to have_current_path new_user_session_path
          within ".alert" do
            expect(page).to have_content "ログインもしくはアカウント登録してください。"
          end
        end
      end

      describe "ログイン後" do
        before do
          login(user)
        end

        it "投稿ボタンをクリックすると, 新規投稿ページに遷移すること" do
          find(".post-button").click

          expect(page).to have_current_path new_post_path
        end
      end
    end
  end
end
