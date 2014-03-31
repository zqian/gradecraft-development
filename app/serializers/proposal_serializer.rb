class ProposalSerializer < ActiveModel::Serializer
  attributes :id, :title, :proposal, :group_id, :feedback, :approved
end
