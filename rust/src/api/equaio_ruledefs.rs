pub const ALGEBRA: &str = r#"
{
    "name": "algebra",
    "context": {
        "base": "arithmetic"
    },
    "variations": [
        {"expr_prefix":  "=(+(A,B),+(B,A))"},
        {"expr_prefix":  "=(*(A,B),*(B,A))"}
    ],
    "normalization": [
        {"expr_prefix": "=(-(0),0)"}
    ],
    "rules": [
        {
            "id": "add_zero",
            "expr_prefix": "=(+(X,0),X)",
            "label": "Addition with 0"
        },
        {
            "id": "mul_one",
            "expr_prefix": "=(*(X,1),X)",
            "label": "Multiplication with 1"
        },
        {
            "id": "mul_zero",
            "expr_prefix": "=(*(X,0),0)",
            "label": "Multiplication with 0"
        },
        {
            "id": "sub_zero",
            "expr_prefix": "=(-(X,0),X)",
            "label": "Subtraction by 0"
        },
        {
            "id": "div_one",
            "expr_prefix": "=(/(X,1),X)",
            "label": "Division by 1"
        },
        {
            "id": "sub_self",
            "expr_prefix": "=(-(X,X),0)",
            "label": "Self subtraction"
        },
        {
            "id": "add_negative_self",
            "expr_prefix": "=(+(X,-(X)),0)",
            "label": "Self subtraction"
        },
        {
            "id": "add_self",
            "expr_prefix": "=(+(X,X),*(2,X))",
            "label": "Self addition"
        },
        {
            "id": "distribution",
            "expr_prefix": "=(*(X,+(A,B)),+(*(X,A),*(X,B)))",
            "label": "Distribution"
        },
        {
            "id": "factor_out_left",
            "expr_prefix": "=(+(*(X,A),*(X,B)),*(X,+(A,B)))",
            "label": "Factoring Out",
            "variations": []
        },
        {
            "id": "factor_out",
            "expr_prefix": "=(+(*(A,X),*(B,X)),*(+(A,B),X))",
            "label": "Factoring Out"
        }
    ]
}
"#;