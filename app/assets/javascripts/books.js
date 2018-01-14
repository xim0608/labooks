if (controller_rails === "books") {
    $(document).on("turbolinks:load", function (e) {
        e.preventDefault();

        $(".modal").modal();

        $("#preview_num").change(function () {
            let val = $(this).val();
            $.ajax({
                type: "post",
                url: "/books/change_show_num",
                data: {show_num: val},
                dataType: "json",
            })
                .then(
                    function () {
                        location.reload();
                    },
                    function () {
                        alert("access failed");
                    }
                );
        });

        if (action_rails === "show" && controller_rails === "books") {
            var app = new Vue({
                el: "#recommend",
                data: {recommends: []},
                created: function () {
                    this.$http.get("/books/" + book_id + "/recommends").then(function (response) {
                        for (var i = 0; i < response.body.length; i++) {
                            this.recommends.push(response.body[i]);
                        }
                    }, function () {
                        // error
                    });
                },
            });

            $.ajax({
                url: "/books/show_review?book_id=" + book_id,
                dataType: "json",
                success: function (json) {
                    if (Object.keys(json).indexOf("url") >= 0) {
                        $("#review").html(`<div class="iframe-content"><iframe src="${json["url"]}" frameborder="0" height="500" width="800"></iframe></div>`)
                    } else {
                        $("#review-error").html("<div class='card-panel red lighten-4'><span class='red-text'>レビューの読み込みに失敗しました</span></div>")
                    }
                }
            })
        }
    });
}