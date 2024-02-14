test_that("custom_render() works", {
    res1 <- list_templates()
    expect_identical(res1 |> length(), 2L)
    expect_identical(
        fs::path_file(res1[[1L]]) |> fs::path_ext_remove(),
        names(res1[1])
    )
    suppressMessages(res2 <- custom_render())
    expect_identical(
        res1, res2
    )
    suppressMessages(
        res2 <- custom_render("report1",
            data = list(title = "Made up"),
            envir = list(geom = 1), quiet = TRUE
        )
    )
    expect_true(file.exists("report1.html"))
    unlink("report1.html")
})
