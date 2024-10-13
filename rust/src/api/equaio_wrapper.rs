use equaio;
use super::equaio_type::*;
use super::equaio_ruledefs as ruledefs;


#[flutter_rust_bridge::frb(opaque)]
pub struct ExpressionWrapper {
  expr: equaio::expression::Expression,
}
impl From<ExpressionWrapper> for equaio::expression::Expression {
  fn from(expr: ExpressionWrapper) -> Self {
    return expr.expr;
  }
}
impl From<equaio::expression::Expression> for ExpressionWrapper {
  fn from(expr: equaio::expression::Expression) -> Self {
    return ExpressionWrapper { expr };
  }
}
impl ExpressionWrapper {
  #[flutter_rust_bridge::frb(sync)]
  pub fn clone(&self) -> ExpressionWrapper {
    ExpressionWrapper { expr: self.expr.clone() }
  }
  #[flutter_rust_bridge::frb(sync)]
  pub fn to_string(&self) -> String {
    return self.expr.to_string(true);
  }
}

#[flutter_rust_bridge::frb(opaque)]
pub struct WorksheetWrapper {
  ws: equaio::worksheet::Worksheet,
}
#[flutter_rust_bridge::frb(opaque)]
pub struct WorkableExpressionSequenceWrapper {
  wseq: equaio::worksheet::WorkableExpressionSequence,
}

#[flutter_rust_bridge::frb(opaque)]
pub struct ExpressionLine {
  pub action: String,
  pub expr: ExpressionWrapper,
  pub label: Option<String>,
  pub is_auto_generated: bool,
}
impl From<equaio::worksheet::ExpressionLine> for ExpressionLine {
  fn from(line: equaio::worksheet::ExpressionLine) -> Self {
    return ExpressionLine {
      action: line.action.to_string(),
      expr: line.expr.into(),
      label: line.label,
      is_auto_generated: line.is_auto_generated,
    }
  }
}
impl From<&equaio::worksheet::ExpressionLine> for ExpressionLine {
  fn from(line: &equaio::worksheet::ExpressionLine) -> Self {
    return ExpressionLine {
      action: line.action.to_string(),
      expr: line.expr.clone().into(),
      label: line.label.clone(),
      is_auto_generated: line.is_auto_generated,
    }
  }
}

#[flutter_rust_bridge::frb(sync)]
pub fn generate_parsed_string(str: String) -> String {
  let ctx = equaio::arithmetic::get_arithmetic_ctx().add_param("x".to_string());
  let expr = equaio::parser::parser::to_expression(str, &ctx).unwrap();
  return expr.to_string(true);
}

#[flutter_rust_bridge::frb(sync)] 
pub fn generate_expression(str: String) -> ExpressionWrapper {
  let ctx = equaio::arithmetic::get_arithmetic_ctx().add_param("x".to_string());
  let expr = equaio::parser::parser::to_expression(str, &ctx).unwrap();
  return ExpressionWrapper { expr };
}

#[flutter_rust_bridge::frb(sync)] 
pub fn expression_to_block(expr: &ExpressionWrapper) -> Block {
  return equaio::block::Block::from(expr.expr.clone()).into();
}

#[flutter_rust_bridge::frb(sync)] 
pub fn expression_to_three_blocks(expr: &ExpressionWrapper) -> (Option<Block>, Option<Block>, Option<Block>) {
  use equaio::block::{Block, block_builder};
  use equaio::expression::Address;
  use equaio::address;
  let expr = &expr.expr;
  if let (Some(lhs), Some(rhs)) = (expr.lhs(), expr.rhs()) {
    let lhs_block = Block::from_expression(lhs, address![0]).into();
    let rhs_block = Block::from_expression(rhs, address![1]).into();
    let eq_block  = block_builder::symbol(expr.symbol.clone(), address![]).into();
    return (Some(lhs_block), Some(eq_block), Some(rhs_block));
  } else {
    let block = Block::from_expression(expr, address![]).into();
    return (None, None, Some(block));
  }
}

#[flutter_rust_bridge::frb(sync)] 
pub fn init_algebra_worksheet(variables: Vec<String>) -> WorksheetWrapper {
  let mut ws = equaio::worksheet::Worksheet::new();
  let algebra_rulestr = ruledefs::ALGEBRA;
  let ruleset = equaio::rule::parse_ruleset_from_json(algebra_rulestr).unwrap();
  let ctx = equaio::arithmetic::get_arithmetic_ctx().add_params(variables);
  ws.set_expression_context(ctx);
  ws.set_normalization_function(|expr,ctx| expr.normalize_algebra(ctx));
  ws.set_rule_map(ruleset.get_rule_map());
  ws.set_get_possible_actions_function(|expr,ctx,addr_vec| 
      equaio::algebra::get_possible_actions::algebra(expr,ctx,addr_vec));
  return WorksheetWrapper { ws };
}

impl WorksheetWrapper {
  #[flutter_rust_bridge::frb(sync)] 
  pub fn introduce_expression(&mut self, expr: ExpressionWrapper) {
    self.ws.introduce_expression(expr.expr);
  }
  #[flutter_rust_bridge::frb(sync)] 
  pub fn get_workable_expression_sequence(&self, index: usize) -> Option<WorkableExpressionSequenceWrapper> {
    let wseq = self.ws.get_workable_expression_sequence(index)?;
    return Some(WorkableExpressionSequenceWrapper { wseq });
  }
}
impl WorkableExpressionSequenceWrapper {
  #[flutter_rust_bridge::frb(sync)] 
  pub fn get_history(&self) -> Vec<ExpressionLine> {
    return self.wseq.history.iter().map(|l| l.into()).collect();
  }
  #[flutter_rust_bridge::frb(sync)] 
  pub fn get_possible_actions(&self, addr_vec: Vec<Address>) -> Vec<(String, ExpressionWrapper)> {
    let addr_vec: Vec<equaio::expression::Address> = addr_vec.into_iter().map(|addr| addr.into()).collect();
    let possible_actions = self.wseq.get_possible_actions(&addr_vec);
    return possible_actions.iter().map(|(act,expr)| (act.to_string(), expr.clone().into())).collect();
  }
  #[flutter_rust_bridge::frb(sync)] 
  pub fn try_apply_action_by_index(&mut self, addr_vec: &Vec<Address>, index: usize) -> bool {
    let addr_vec: Vec<equaio::expression::Address> = addr_vec.iter().map(|addr| addr.clone().into()).collect();
    return self.wseq.try_apply_action_by_index(&addr_vec, index);
  }
  
  
  
}