module Researchers
  class InvitationsController < Devise::InvitationsController
    # path after inviter submits invite form
    def after_invite_path_for(_, _)
      admin_researchers_path
    end

    # path after invitee submits password form
    def after_accept_path_for(_)
      admin_root_path
    end
  end
end
