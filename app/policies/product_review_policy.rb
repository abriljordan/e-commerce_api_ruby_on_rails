class ProductReviewPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present? && !user.reviewed_product?(record.product)
  end

  def update?
    user.present? && (user == record.user || user.admin?)
  end

  def destroy?
    user.present? && (user == record.user || user.admin?)
  end

  def approve?
    user.present? && user.admin?
  end

  def reject?
    user.present? && user.admin?
  end

  class Scope < Scope
    def resolve
      if user&.admin?
        scope.all
      else
        scope.approved
      end
    end
  end
end 