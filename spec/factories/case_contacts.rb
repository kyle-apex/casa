FactoryBot.define do
  factory :case_contact do
    association :creator, factory: :user
    casa_case

    contact_types { [create(:contact_type)] }
    duration_minutes { 60 }
    occurred_at { Time.zone.now }
    contact_made { false }
    medium_type { CaseContact::CONTACT_MEDIUMS.first }
    want_driving_reimbursement { false }
    deleted_at { nil }
    status { "active" }
    draft_case_ids { [casa_case&.id] }

    trait :multi_line_note do
      notes { "line1\nline2\nline3" }
    end

    trait :long_note do
      notes { "1234567890 " * 11 } # longer than NOTES_CHARACTER_LIMIT
    end

    trait :miles_driven_no_reimbursement do
      miles_driven { 20 }
      want_driving_reimbursement { false }
    end

    trait :wants_reimbursement do
      miles_driven { 456 }
      want_driving_reimbursement { true }
    end

    trait :started_status do
      casa_case { nil }
      draft_case_ids { [] }
      medium_type { nil }
      occurred_at { nil }
      duration_minutes { nil }
      notes { nil }
      miles_driven { 0 }
      status { "started" }
    end

    trait :details_status do
      casa_case { nil }
      draft_case_ids { [1] }
      notes { nil }
      miles_driven { 0 }
      status { "details" }
    end

    trait :notes_status do
      casa_case { nil }
      draft_case_ids { [1] }
      miles_driven { 0 }
      status { "notes" }
    end

    trait :expenses_status do
      draft_case_ids { [1] }
      status { "expenses" }
    end

    after(:create) do |case_contact, evaluator|
      if evaluator.metadata
        case_contact.update_columns(metadata: evaluator.metadata)
      elsif case_contact.status
        case_contact.update_columns(metadata: {"status" => {case_contact.status => case_contact.created_at}})
      end
    end

    trait :with_org_topics do
      after(:create) do |case_contact, _|
        return if case_contact.casa_case.nil?

        casa_org = case_contact.casa_case.casa_org
        casa_org.contact_topics.active.each do |contact_topic|
          case_contact.contact_topic_answers << build(:contact_topic_answer, contact_topic: contact_topic)
        end
      end
    end
  end
end
