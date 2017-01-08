RSpec.describe ROM::Relation, '#right_join' do
  subject(:relation) { relations[:tasks] }

  let(:users) { relations[:users] }

  include_context 'users and tasks'

  with_adapters :postgres, :mysql do
    it 'joins relations using left outer join' do
      relation.insert id: 3, title: 'Unassigned'

      result = relation.
                 right_join(:users, id: :user_id).
                 select(:title, users[:name])

      expect(result.schema.map(&:name)).to eql(%i[title name])

      expect(result.to_a).to match_array([
        { name: 'Joe', title: "Joe's task" },
        { name: 'Jane', title: "Jane's task" }
      ])
    end

    context 'with associations' do
      before do
        conf.relation(:users) do
          schema(infer: true) do
            associations { has_many :tasks }
          end
        end

        conf.relation(:tasks) do
          schema(infer: true) do
            associations { belongs_to :user }
          end
        end
      end

      it 'joins relation with join keys inferred' do
        relation.insert id: 3, title: 'Unassigned'

        result = relation.
                   right_join(users).
                   select(:title, users[:name])

        expect(result.schema.map(&:name)).to eql(%i[title name])

        expect(result.to_a).to match_array([
                                             { name: 'Joe', title: "Joe's task" },
                                             { name: 'Jane', title: "Jane's task" }
                                           ])
      end
    end
  end
end