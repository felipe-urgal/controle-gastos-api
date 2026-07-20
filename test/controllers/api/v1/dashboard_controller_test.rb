require "test_helper"

class Api::V1::DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @token = SessionTokenService.generate_token

    UserSession.create!(
      user: users(:one),
      token_digest: SessionTokenService.digest(@token),
      expires_at: 1.day.from_now
    )
  end

  test "returns summary, evolution, top categories, accounts and recent transactions for the given month" do
    get "/api/v1/dashboard", params: { year: 2026, month: 7 }, headers: auth_headers

    assert_response :success
    body = JSON.parse(response.body)["data"]

    assert_equal(
      { "year" => 2026, "month" => 7, "income" => 500000, "expense" => 30000, "balance" => 470000 },
      body["summary"]
    )

    assert_equal 1, body["accounts"].length
    assert_equal accounts(:checking).id, body["accounts"].first["id"]
    assert_equal 100000, body["accounts"].first["balance"]

    assert_equal 4, body["recentTransactions"].length
    assert_equal "Não deve contar nos totais", body["recentTransactions"].first["description"]

    assert_equal 6, body["evolution"].length
    assert_equal({ "year" => 2026, "month" => 7 }, body["evolution"].last.slice("year", "month"))

    june = body["evolution"].find { |m| m["year"] == 2026 && m["month"] == 6 }
    assert_equal 20000, june["expense"]
    assert_equal 0, june["income"]

    assert_equal 1, body["topCategories"].length
    assert_equal categories(:one).id, body["topCategories"].first["categoryId"]
    assert_equal 30000, body["topCategories"].first["total"]
  end

  test "requires authentication" do
    get "/api/v1/dashboard"

    assert_response :unauthorized
  end

  private

  def auth_headers
    { "Authorization" => "Bearer #{@token}" }
  end
end
