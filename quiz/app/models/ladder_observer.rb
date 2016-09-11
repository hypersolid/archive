class LadderObserver < ActiveRecord::Observer
  observe :ladder

  def after_create(ladder)
    ladder.leader.ladder.update_wings if ladder.leader && ladder.leader.ladder
  end

  def after_save(ladder)
    return false if !ladder.score_changed? || ladder.combined_score_changed?

    ladder.update_combined_score
    ladder.leader.ladder.update_combined_score if ladder.leader
    
    changed_at = ladder.tournament.reload.refresh_scores!(false)

    if (ladder.reload.position_changed_at.to_i == changed_at.to_i) && (ladder.position_old > ladder.position)
      ladder.delay.push
      # ladder.user.delay.post_fb_feed(ladder) if ladder.prize > 0
    end

    ladder.leader.ladder.push if ladder.leader && ladder.leader.ladder.reload.position_changed_at.to_i == changed_at.to_i

    # send notifications when user moves up the ladder because of his wingman
    moved_rows = Ladder.moved_at(changed_at).where('ladders.id != ?', ladder.id)
    moved_rows.where(:users => {:email_movement => true}).each {|row| EmailFallback.delay.proxy(:movement, row, ladder) if row.up?}

    # send notifications when your Facebook friend overtakes you
    friends_rows = moved_rows.where(:user_id => FacebookFriend.where(:friend_id => ladder.user_id).all.map(&:user_id))
    friends_rows.where(:users => {:email_overtaken => true}).each {|row| EmailFallback.delay.proxy(:overtaken, row, ladder) if row.position > ladder.position && ladder.position_old && row.position_old < ladder.position_old}
  end

end
